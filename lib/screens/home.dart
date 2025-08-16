import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:trail_sync/providers/auth_provider.dart';
import 'package:intl/intl.dart';

import 'package:trail_sync/providers/run_provider.dart';
import 'package:trail_sync/screens/activity_mini_map.dart';
import 'package:trail_sync/screens/run_details.dart';
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

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: runs.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return WeeklyStatsCard(
                    totalActivities: totalActivities,
                    totalDistance: totalDistance,
                    totalTime: totalTime,
                  );
                }

                final run = runs[index - 1];
                final pace = run.avgPaceMinPerKm != null
                    ? "${run.avgPaceMinPerKm!.toStringAsFixed(2)} min/km"
                    : "-";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RunDetailScreen(run: run),
                      ),
                    );
                  },
                  child: _ActivityCard(
                    username: userAsync.maybeWhen(
                      data: (user) => user?.displayName ?? 'You',
                      orElse: () => 'You',
                    ),
                    activityType: run.mode ?? 'Activity',
                    distance: "${(run.distanceKm ?? 0).toStringAsFixed(2)} km",
                    duration: _formatDuration(
                      Duration(seconds: run.durationSec ?? 0),
                    ),
                    pace: pace,
                    date: run.startTime,
                    trailPoints: run.points
                        .map((p) => LatLng(p.lat, p.lng))
                        .toList(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String username;
  final String activityType;
  final String distance;
  final String duration;
  final String pace;
  final List<LatLng> trailPoints;
  final DateTime? date;

  const _ActivityCard({
    super.key,
    required this.username,
    required this.activityType,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.trailPoints,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = date != null
        ? DateFormat('MMMM d, y \'at\' h:mm a').format(date!)
        : '';

    return Card(
      elevation: 1,
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$activityType • $formattedDate'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Distance: $distance',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Time: $duration',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Pace: $pace',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (trailPoints.isNotEmpty)
              ActivityMiniMap(points: trailPoints, height: 120),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  final hours = twoDigits(d.inHours);
  final minutes = twoDigits(d.inMinutes.remainder(60));
  final seconds = twoDigits(d.inSeconds.remainder(60));
  return hours != "00" ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
}
