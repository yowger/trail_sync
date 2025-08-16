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
}
