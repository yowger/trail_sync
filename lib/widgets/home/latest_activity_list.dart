import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:trail_sync/models/run.dart';
import 'package:trail_sync/screens/run_details.dart';
import 'package:trail_sync/widgets/home/activity_card.dart';

class LatestActivityList extends StatelessWidget {
  final List<Run> runs;
  final AsyncValue<User?> userAsync;

  const LatestActivityList({
    super.key,
    required this.runs,
    required this.userAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Activities",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to full activities list screen
                  },
                  child: Row(
                    children: [
                      Text(
                        "See all",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                        weight: 800,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: runs.length,
            itemBuilder: (context, index) {
              final run = runs[index];
              final pace = run.avgPaceMinPerKm?.toStringAsFixed(2);

              return Material(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RunDetailScreen(run: run),
                      ),
                    );
                  },
                  child: ActivityCard(
                    activityName: run.name,
                    username: userAsync.maybeWhen(
                      data: (user) => user?.displayName ?? 'You',
                      orElse: () => 'You',
                    ),
                    activityType: run.mode,
                    distance: run.distanceKm.toStringAsFixed(2),
                    duration: _formatDuration(
                      Duration(seconds: run.durationSec),
                    ),
                    pace: pace,
                    date: run.startTime,
                    trailPoints: run.points
                        .map((p) => LatLng(p.lat, p.lng))
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
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
