import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trail_sync/models/run.dart';
import 'package:trail_sync/providers/auth_provider.dart';
import 'package:trail_sync/services/run_service.dart';

final runServiceProvider = Provider<RunService>((ref) {
  return RunService();
});

final recentRunsProvider = FutureProvider.autoDispose<List<Run>>((ref) async {
  final userId = ref.watch(authStateProvider).value?.uid;
  if (userId == null) return [];
  final service = ref.watch(runServiceProvider);
  return service.fetchRecentRuns(userId: userId);
});
