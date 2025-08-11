import 'dart:async';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class LocationService {
  static LocationService? _instance;
  LocationService._internal();

  factory LocationService() {
    _instance ??= LocationService._internal();
    return _instance!;
  }

  String? _currentMode;
  bool _isPaused = false;
  bool _isTracking = false;
  List<Map<String, dynamic>> _currentSession = [];

  Stream<bool> get isTrackingStream => _isTrackingController.stream;

  final _isTrackingController = StreamController<bool>.broadcast();
  final _locationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get locationStream =>
      _locationStreamController.stream;

  Future<void> init() async {
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      if (_isPaused) return;

      final point = {
        'lat': location.coords.latitude,
        'lng': location.coords.longitude,
        'timestamp': location.timestamp,
        'mode': _currentMode,
      };
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

  Future<void> startTracking(String mode) async {
    await setMode(mode);
    _currentSession.clear();
    _isPaused = false;
    _isTracking = true;
    _isTrackingController.add(true);
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
    await bg.BackgroundGeolocation.stop();
    await bg.BackgroundGeolocation.setConfig(bg.Config(startOnBoot: false));
    _isTracking = false;
    _isTrackingController.add(false);
    print("Session ended: $_currentSession");
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

  List<Map<String, dynamic>> get currentSession =>
      List.unmodifiable(_currentSession);

  bool get isPaused => _isPaused;
  bool get isTracking => _isTracking;
}
