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
    String formattedTime = '';
    if (date != null) {
      if (date!.year == now.year) {
        formattedDate = DateFormat('MMM d').format(date!);
      } else {
        formattedDate = DateFormat('MMM d, yyyy').format(date!);
      }
      formattedTime = DateFormat('h:mm a').format(date!);
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
                      radius: 14,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        getActivityIcon(activityType),
                        size: 18,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      getActivityLabel(activityType),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                if (date != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (activityName != null && activityName!.isNotEmpty)
              Text(
                activityName!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StatItem(value: duration, label: "Duration"),
                ),
                Expanded(
                  child: StatItem(
                    value: distance,
                    unit: "km",
                    label: "Distance",
                  ),
                ),
                Expanded(
                  child: StatItem(
                    value: pace ?? "0",
                    unit: "/km",
                    label: "Avg Pace",
                  ),
                ),
              ],
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
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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

String getActivityLabel(String type) {
  switch (type.toLowerCase()) {
    case "running":
      return "Run";
    case "cycling":
      return "Cycle";
    case "walking":
      return "Walk";
    default:
      return "Activity";
  }
}

String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1).toLowerCase();
}
