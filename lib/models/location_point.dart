class LocationPoint {
  final double lat;
  final double lng;
  final DateTime timestamp;
  final String? mode;

  LocationPoint({
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.mode,
  });

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    'timestamp': timestamp.toIso8601String(),
    'mode': mode,
  };

  factory LocationPoint.fromJson(Map<String, dynamic> json) => LocationPoint(
    lat: json['lat'] as double,
    lng: json['lng'] as double,
    timestamp: DateTime.parse(json['timestamp']),
    mode: json['mode'] as String?,
  );
}
