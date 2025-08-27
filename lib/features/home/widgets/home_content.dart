import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:trail_sync/models/run.dart';
import 'package:trail_sync/features/home/widgets/latest_activity_list.dart';
import 'package:trail_sync/widgets/ui/app_divider.dart';
import 'package:trail_sync/widgets/weekly_activity_card.dart';

class HomeContent extends StatelessWidget {
  final List<Run> runs;
  final AsyncValue<User?> userAsync;

  const HomeContent({super.key, required this.runs, required this.userAsync});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklyRuns = runs.where((r) => (r.endTime).isAfter(weekAgo)).toList();

    final totalDistance = weeklyRuns.fold<double>(
      0,
      (sum, r) => sum + (r.distanceKm),
    );
    final totalTime = weeklyRuns.fold<Duration>(
      Duration.zero,
      (sum, r) => sum + Duration(seconds: r.durationSec),
    );
    final totalActivities = weeklyRuns.length;

    return ListView(
      children: [
        WeeklyStatsCard(
          totalActivities: totalActivities,
          totalDistance: totalDistance,
          totalTime: totalTime,
        ),
        AppDivider(),
        LatestActivityList(runs: runs, userAsync: userAsync),
      ],
    );
  }
}
