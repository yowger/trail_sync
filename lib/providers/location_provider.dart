import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final activityModeProvider = StateProvider<String?>((ref) => null);

final locationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(locationServiceProvider).locationStream;
});

final isPausedProvider = StateProvider<bool>((ref) {
  return ref.watch(locationServiceProvider).isPaused;
});
