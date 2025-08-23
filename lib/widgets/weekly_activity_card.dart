import 'package:flutter/material.dart';

class WeeklyStatsCard extends StatelessWidget {
  final int totalActivities;
  final double totalDistance;
  final Duration totalTime;

  const WeeklyStatsCard({
    super.key,
    required this.totalActivities,
    required this.totalDistance,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.3,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'Activities',
                  value: totalActivities.toString(),
                  changePercent: 12.5,
                ),
                _StatItem(
                  label: 'Distance',
                  value: '${totalDistance.toStringAsFixed(2)} km',
                  changePercent: 12.5,
                ),
                _StatItem(
                  label: 'Time',
                  value: _formatDuration(totalTime),
                  changePercent: 12.5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}h';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final double? changePercent;

  const _StatItem({
    required this.label,
    required this.value,
    this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    Color? changeColor;
    IconData? changeIcon;

    if (changePercent != null) {
      if (changePercent! > 0) {
        changeColor = Colors.green;
        changeIcon = Icons.arrow_upward;
      } else if (changePercent! < 0) {
        changeColor = Colors.red;
        changeIcon = Icons.arrow_downward;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Row(
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            if (changePercent != null) ...[
              const SizedBox(width: 4),
              Icon(changeIcon, size: 12, color: changeColor),
              const SizedBox(width: 2),
              Text(
                '${changePercent!.abs().toStringAsFixed(0)}%',
                style: TextStyle(color: changeColor, fontSize: 12),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
