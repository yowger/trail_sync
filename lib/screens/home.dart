import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trail_sync/providers/auth_provider.dart';

import 'package:trail_sync/providers/run_provider.dart';
import 'package:trail_sync/widgets/home/latest_activity_list.dart';
import 'package:trail_sync/widgets/weekly_activity_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentRunsAsync = ref.watch(recentRunsProvider);
    final userAsync = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: userAsync.when(
          data: (user) {
            if (user == null) return const Text("Welcome");
            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  user.displayName ?? 'You',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Text("Error"),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[300], height: 1),
        ),
      ),
      body: SafeArea(
        child: recentRunsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text("Error loading runs")),
          data: (runs) {
            if (runs.isEmpty) return const Center(child: Text("No runs yet"));

            final now = DateTime.now();
            final weekAgo = now.subtract(const Duration(days: 7));
            final weeklyRuns = runs
                .where((r) => (r.endTime ?? r.startTime!).isAfter(weekAgo))
                .toList();

            final totalDistance = weeklyRuns.fold<double>(
              0,
              (sum, r) => sum + (r.distanceKm ?? 0),
            );
            final totalTime = weeklyRuns.fold<Duration>(
              Duration.zero,
              (sum, r) => sum + Duration(seconds: r.durationSec ?? 0),
            );
            final totalActivities = weeklyRuns.length;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                WeeklyStatsCard(
                  totalActivities: totalActivities,
                  totalDistance: totalDistance,
                  totalTime: totalTime,
                ),
                const SizedBox(height: 16),

                LatestActivityList(runs: runs, userAsync: userAsync),
              ],
            );
          },
        ),
      ),
    );
  }
}
