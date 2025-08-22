import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final String? activityName;
  final String username;
  final String activityType;
  final String distance;
  final String duration;
  final String? pace;
  final List<LatLng> trailPoints;
  final DateTime? date;

  const ActivityCard({
    super.key,
    this.activityName,
    required this.username,
    required this.activityType,
    required this.distance,
    required this.duration,
    this.pace,
    required this.trailPoints,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String formattedDate = '';

    if (date != null) {
      if (date!.year == now.year) {
        formattedDate = DateFormat('MMM d').format(date!);
      } else {
        formattedDate = DateFormat('MMM d, yyyy').format(date!);
      }
    }

    return Card(
      color: Colors.white,
      elevation: 0.3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(
                        getActivityIcon(activityType),
                        size: 18,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      capitalize(activityName ?? "Daily Run"),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatItem(value: duration, label: "Time"),
                  StatItem(value: distance, unit: "km", label: "Distance"),
                  StatItem(value: pace ?? "0", unit: "/km", label: "Avg Pace"),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String label;
  final String? unit;

  const StatItem({
    super.key,
    required this.value,
    required this.label,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            if (unit != null) ...[
              const SizedBox(width: 2),
              Text(
                unit!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        Text(label, style: TextStyle(fontSize: 12.75, color: Colors.grey[600])),
      ],
    );
  }
}

IconData getActivityIcon(String activityType) {
  switch (activityType.toLowerCase()) {
    case "running":
      return Icons.directions_run;
    case "walking":
      return Icons.directions_walk;
    case "cycling":
    case "biking":
      return Icons.directions_bike;
    default:
      return Icons.fitness_center;
  }
}

String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}
