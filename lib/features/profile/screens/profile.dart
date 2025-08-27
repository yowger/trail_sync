import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trail_sync/providers/run_provider.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentRunsAsync = ref.watch(recentRunsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: recentRunsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error loading runs")),
        data: (runs) {
          if (runs.isEmpty) {
            return const Center(child: Text("No runs yet"));
          }

          // Prepare last 7 days
          final now = DateTime.now();
          final weekAgo = now.subtract(const Duration(days: 6));
          final dailyDistances = List.generate(7, (_) => 0.0);
          final dayLabels = List.generate(
            7,
            (i) => DateFormat.E().format(weekAgo.add(Duration(days: i))),
          );

          for (var run in runs) {
            final runDate = run.startTime ?? run.endTime ?? DateTime.now();
            if (runDate.isAfter(weekAgo)) {
              final dayIndex = runDate.difference(weekAgo).inDays;
              if (dayIndex >= 0 && dayIndex < 7) {
                dailyDistances[dayIndex] += run.distanceKm ?? 0;
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Weekly Distance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _DistanceLineChart(
                  distances: dailyDistances,
                  labels: dayLabels,
                ),
                const SizedBox(height: 32),
                // ... you can add more stats or list of recent runs here
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DistanceLineChart extends StatelessWidget {
  final List<double> distances;
  final List<String> labels;

  const _DistanceLineChart({
    super.key,
    required this.distances,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      distances.length,
      (index) => FlSpot(index.toDouble(), distances[index]),
    );

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < labels.length) {
                    return Text(
                      labels[index],
                      style: const TextStyle(fontSize: 12),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
