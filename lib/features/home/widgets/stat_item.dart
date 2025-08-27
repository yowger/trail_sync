import 'package:flutter/material.dart';

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
        Text(label, style: TextStyle(fontSize: 12)),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (unit != null) ...[
              const SizedBox(width: 2),
              Text(
                unit!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
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
