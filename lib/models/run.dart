import 'package:trail_sync/models/run_model.dart';

class Run {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String mode;
  final double distanceKm;
  final int durationSec;
  final double? avgPaceMinPerKm;
  final DateTime startTime;
  final DateTime endTime;
  final List<RunPoint> points;

  Run({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.mode,
    required this.distanceKm,
    required this.durationSec,
    this.avgPaceMinPerKm,
    required this.startTime,
    required this.endTime,
    required this.points,
  });

  factory Run.fromMap(Map<String, dynamic> map) {
    return Run(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String? ?? 'Unnamed Run',
      description: map['description'] as String? ?? '',
      mode: map['mode'] as String? ?? 'running',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
      durationSec: map['durationSec'] as int? ?? 0,
      avgPaceMinPerKm: (map['avgPaceMinPerKm'] as num?)?.toDouble(),
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: DateTime.parse(map['endTime'] as String),
      points:
          (map['points'] as List<dynamic>?)
              ?.map((p) => RunPoint.fromMap(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'mode': mode,
      'distanceKm': distanceKm,
      'durationSec': durationSec,
      'avgPaceMinPerKm': avgPaceMinPerKm,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'points': points.map((p) => p.toMap()).toList(),
    };
  }
}
