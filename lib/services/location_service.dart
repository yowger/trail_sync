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
  List<Map<String, dynamic>> _currentSession = [];

  final _locationStreamController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get locationStream =>
      _locationStreamController.stream;

  Future<void> init() async {
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
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
        stopOnTerminate: false,
        startOnBoot: true,
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

    await bg.BackgroundGeolocation.start();
  }

  Future<void> stopTracking() async {
    await bg.BackgroundGeolocation.stop();

    print("Session ended: $_currentSession");
  }

  List<Map<String, dynamic>> get currentSession =>
      List.unmodifiable(_currentSession);
}
