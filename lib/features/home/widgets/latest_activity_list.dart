import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:go_router/go_router.dart';

import 'package:trail_sync/helpers/run_format.dart';
import 'package:trail_sync/models/run.dart';
import 'package:trail_sync/features/home/screens/run_details.dart';
import 'package:trail_sync/features/home/widgets/activity_card.dart';
import 'package:trail_sync/widgets/ui/app_divider.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: runs.length,
          separatorBuilder: (context, index) => AppDivider(),
          itemBuilder: (context, index) {
            final run = runs[index];
            final pace = run.avgPaceMinPerKm?.toStringAsFixed(2);

            return ActivityCard(
              onCardTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RunDetailScreen(run: run)),
                );
              },

              onAvatarTap: () {
                final userId = run.user.id;
                context.push('/user/$userId');
              },

              activityName: run.name,
              username: userAsync.maybeWhen(
                data: (user) => run.user.name,
                orElse: () => 'You',
              ),
              address: run.address,
              activityType: run.mode,
              distance: run.distanceKm.toStringAsFixed(2),
              duration: formatDuration(Duration(seconds: run.durationSec)),
              pace: pace,
              date: run.startTime,
              trailPoints: run.points.map((p) => LatLng(p.lat, p.lng)).toList(),
            );
          },
        ),
      ],
    );
  }
}
