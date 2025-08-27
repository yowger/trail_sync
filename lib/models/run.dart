import 'package:latlong2/latlong.dart';
import 'package:trail_sync/models/user_model.dart';

class RunPoint {
  final double lat;
  final double lng;
  final DateTime timestamp;

  RunPoint({required this.lat, required this.lng, required this.timestamp});

  factory RunPoint.fromMap(Map<String, dynamic> map) {
    return RunPoint(
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'timestamp': timestamp.toIso8601String()};
  }

  LatLng toLatLng() => LatLng(lat, lng);
}

class Run {
  final String id;
  final AppUser user;
  final String address;
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
    required this.user,
    required this.address,
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
      user: AppUser.fromMap(map['user'] as Map<String, dynamic>),
      address: map['address'] as String,
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
      'user': user.toMap(),
      'address': address,
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
