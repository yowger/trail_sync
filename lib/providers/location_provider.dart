import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trail_sync/models/location_point.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final activityModeProvider = StateProvider<String?>((ref) => null);

final locationStreamProvider = StreamProvider<LocationPoint>((ref) {
  return ref.watch(locationServiceProvider).locationStream;
});

final totalTimeStreamProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.totalTimeStream;
});

final movingTimeStreamProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.movingTimeStream;
});

final isPausedProvider = StateProvider<bool>((ref) {
  return ref.watch(locationServiceProvider).isPaused;
});

final isTrackingProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.isTrackingStream;
});
