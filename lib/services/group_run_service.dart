import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trail_sync/models/group_event_run.dart';

class GroupRunService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new group run event
  Future<void> createEvent(GroupRunEvent event) async {
    final docRef = _firestore.collection("events").doc(event.id);
    await docRef.set(event.toMap());
  }

  /// Fetch upcoming events (scheduled or active)
  Future<List<GroupRunEvent>> fetchUpcomingEvents() async {
    final now = DateTime.now().toIso8601String();
    final snapshot = await _firestore
        .collection("events")
        // .where('startTime', isGreaterThanOrEqualTo: now)
        // .orderBy('startTime')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final participantsData = List<Map<String, dynamic>>.from(
        data['participants'],
      );
      final participants = participantsData.map((p) {
        return Participant(
          userId: p['userId'],
          status: p['status'],
          joinedAt: DateTime.parse(p['joinedAt']),
          currentDistanceKm: (p['currentDistanceKm'] ?? 0).toDouble(),
          lastUpdated: DateTime.parse(p['lastUpdated']),
        );
      }).toList();

      return GroupRunEvent(
        id: data['id'],
        routeId: data['routeId'],
        name: data['name'],
        description: data['description'],
        createdBy: data['createdBy'],
        startTime: DateTime.parse(data['startTime']),
        actualStartTime: data['actualStartTime'] != null
            ? DateTime.parse(data['actualStartTime'])
            : null,
        endTime: data['endTime'] != null
            ? DateTime.parse(data['endTime'])
            : null,
        status: data['status'],
        mode: data['mode'],
        distanceTargetKm: (data['distanceTargetKm'] ?? 0).toDouble(),
        location: data['location'] != null
            ? EventLocation(
                lat: data['location']['lat'],
                lng: data['location']['lng'],
                address: data['location']['address'],
              )
            : null,
        participants: participants,
        visibility: data['visibility'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    }).toList();
  }

  /// Update participant distance and last location
  Future<void> updateParticipantLocation({
    required String eventId,
    required String userId,
    required double latitude,
    required double longitude,
    double? distanceKm,
  }) async {
    final docRef = _firestore.collection("events").doc(eventId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data()!;
    final participants = List<Map<String, dynamic>>.from(data['participants']);

    for (var p in participants) {
      if (p['userId'] == userId) {
        p['currentDistanceKm'] = distanceKm ?? p['currentDistanceKm'];
        p['lastUpdated'] = DateTime.now().toIso8601String();
        break;
      }
    }

    await docRef.update({'participants': participants});
  }

  /// Optionally: use subcollection for real-time location tracking
  Future<void> updateParticipantLocationSub({
    required String eventId,
    required String userId,
    required double latitude,
    required double longitude,
    double? distanceKm,
  }) async {
    final subDoc = _firestore
        .collection("events")
        .doc(eventId)
        .collection("participants")
        .doc(userId);

    await subDoc.set({
      'lat': latitude,
      'lng': longitude,
      'currentDistanceKm': distanceKm ?? 0.0,
      'lastUpdated': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }
}
