import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trail_sync/models/run.dart';

class RunService {
  final FirebaseFirestore _firestore;

  RunService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Run>> fetchRecentRuns({
    required String userId,
    int limit = 3,
  }) async {
    final snapshot = await _firestore
        .collection('runs')
        .where('user.id', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => Run.fromMap(doc.data())).toList();
  }
}
