import 'package:geolocator/geolocator.dart';
import 'package:app_settings/app_settings.dart';

Future<bool> handleLocationPermission() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    AppSettings.openAppSettings(type: AppSettingsType.location);
    return false;
  }

  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    AppSettings.openAppSettings(type: AppSettingsType.location);
    return false;
  }

  return true;
}
