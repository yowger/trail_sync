import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

import 'package:trail_sync/models/location_point.dart';

class LocationService {
  static LocationService? _instance;
  LocationService._internal();
  factory LocationService() {
    _instance ??= LocationService._internal();
    return _instance!;
  }

  String? _currentMode;
  DateTime? _startTime;
  DateTime? _endTime;
  Timer? _timer;

  bool _isPaused = false;
  bool _isTracking = false;
  Duration _movingElapsed = Duration.zero;

  final List<LocationPoint> _currentSession = [];

  final _totalTimeController = StreamController<Duration>.broadcast();
  final _movingTimeController = StreamController<Duration>.broadcast();
  final _isTrackingController = StreamController<bool>.broadcast();
  final _locationStreamController = StreamController<LocationPoint>.broadcast();

  Stream<Duration> get totalTimeStream => _totalTimeController.stream;
  Stream<Duration> get movingTimeStream => _movingTimeController.stream;
  Stream<bool> get isTrackingStream => _isTrackingController.stream;
  Stream<LocationPoint> get locationStream => _locationStreamController.stream;

  bool get isPaused => _isPaused;
  bool get isTracking => _isTracking;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  List<LocationPoint> get currentSession => List.unmodifiable(_currentSession);

  Future<void> init() async {
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      if (_isPaused) return;

      final point = LocationPoint(
        lat: location.coords.latitude,
        lng: location.coords.longitude,
        timestamp: DateTime.parse(location.timestamp),
        mode: _currentMode,
      );

      _currentSession.add(point);
      _locationStreamController.add(point);
    });

    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] $location');
    });

    await bg.BackgroundGeolocation.ready(
      bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10,
        stopOnTerminate: true,
        startOnBoot: false,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
      ),
    );
  }

  Future<void> setMode(String mode) async {
    _currentMode = mode;
    switch (mode) {
      case 'running':
        await bg.BackgroundGeolocation.setConfig(
          bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 5,
            activityType: bg.Config.ACTIVITY_TYPE_FITNESS,
          ),
        );
        break;
      case 'cycling':
        await bg.BackgroundGeolocation.setConfig(
          bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 10,
            activityType: bg.Config.ACTIVITY_TYPE_OTHER,
          ),
        );
        break;
      case 'walking':
        await bg.BackgroundGeolocation.setConfig(
          bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 3,
            activityType: bg.Config.ACTIVITY_TYPE_FITNESS,
          ),
        );
        break;
    }
  }

  void _startDurationTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startTime != null) {
        final total = DateTime.now().difference(_startTime!);
        _totalTimeController.add(total);

        if (!_isPaused) {
          _movingElapsed += const Duration(seconds: 1);
          _movingTimeController.add(_movingElapsed);
        }
      }
    });
  }

  Future<void> startTracking(String mode) async {
    await setMode(mode);
    _currentSession.clear();

    _movingElapsed = Duration.zero;
    _isPaused = false;
    _isTracking = true;
    _startTime = DateTime.now();
    _endTime = null;

    _isTrackingController.add(true);
    _startDurationTimer();

    await bg.BackgroundGeolocation.setConfig(bg.Config(startOnBoot: true));
    await bg.BackgroundGeolocation.start();
  }

  Future<void> pauseTracking() async {
    _isPaused = true;
    print("Tracking paused.");
  }

  Future<void> resumeTracking() async {
    _isPaused = false;
    print("Tracking resumed.");
  }

  Future<void> stopTracking() async {
    _timer?.cancel();
    _endTime = DateTime.now();
    _isTracking = false;
    _isTrackingController.add(false);

    await bg.BackgroundGeolocation.stop();
    await bg.BackgroundGeolocation.setConfig(bg.Config(startOnBoot: false));

    print("Session ended: ${_currentSession.map((e) => e.toJson()).toList()}");
  }

  Future<bg.Location?> getCurrentLocation() async {
    try {
      final location = await bg.BackgroundGeolocation.getCurrentPosition(
        persist: false,
        samples: 1,
        timeout: 30,
      );
      return location;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  void dispose() {
    _timer?.cancel();
    _totalTimeController.close();
    _movingTimeController.close();
    _isTrackingController.close();
    _locationStreamController.close();
  }
}
