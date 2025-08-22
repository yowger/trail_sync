class GroupRunEvent {
  final String id;
  final String? routeId;
  final String name;
  final String description;
  final String createdBy;
  final DateTime startTime;
  final DateTime? actualStartTime;
  final DateTime? endTime;
  final String status;
  final String mode;
  final double? distanceTargetKm;
  final EventLocation? location;
  final List<Participant> participants;
  final String visibility;
  final DateTime createdAt;

  GroupRunEvent({
    required this.id,
    this.routeId,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.startTime,
    this.actualStartTime,
    this.endTime,
    required this.status,
    required this.mode,
    this.distanceTargetKm,
    this.location,
    required this.participants,
    required this.visibility,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "description": description,
    "createdBy": createdBy,
    "startTime": startTime.toIso8601String(),
    "actualStartTime": actualStartTime?.toIso8601String(),
    "endTime": endTime?.toIso8601String(),
    "status": status,
    "mode": mode,
    "distanceTargetKm": distanceTargetKm,
    "location": location?.toMap(),
    "participants": participants.map((p) => p.toMap()).toList(),
    "visibility": visibility,
    "createdAt": createdAt.toIso8601String(),
  };
}

class EventLocation {
  final double lat;
  final double lng;
  final String address;

  EventLocation({required this.lat, required this.lng, required this.address});

  Map<String, dynamic> toMap() => {"lat": lat, "lng": lng, "address": address};
}

class Participant {
  final String userId;
  final String status; // ready | running | finished
  final DateTime joinedAt;
  double currentDistanceKm;
  DateTime lastUpdated;

  Participant({
    required this.userId,
    required this.status,
    required this.joinedAt,
    this.currentDistanceKm = 0.0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    "userId": userId,
    "status": status,
    "joinedAt": joinedAt.toIso8601String(),
    "currentDistanceKm": currentDistanceKm,
    "lastUpdated": lastUpdated.toIso8601String(),
  };

  double progressPercent(double totalDistance) {
    return (currentDistanceKm / totalDistance).clamp(0.0, 1.0);
  }
}
