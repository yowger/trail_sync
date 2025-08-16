import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DistanceLineChart extends StatelessWidget {
  final List<double> distances;
  final List<String> labels;

  const DistanceLineChart({
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
            ),
          ],
        ),
      ),
    );
  }
}
