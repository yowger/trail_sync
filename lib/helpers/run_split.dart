import 'package:latlong2/latlong.dart';
import 'package:trail_sync/models/run.dart';

class Split {
  final int kilometer;
  final double distance;
  final Duration duration;
  final double pace;

  Split({
    required this.kilometer,
    required this.distance,
    required this.duration,
    required this.pace,
  });
}

// List<Split> calculateSplits(List<RunPoint> points) {
//   final distanceCalc = Distance();
//   List<Split> splits = [];

//   if (points.length < 2) return splits;

//   double splitDistance = 0.0;
//   int splitCounter = 1;
//   DateTime splitStartTime = points.first.timestamp;

//   for (int i = 1; i < points.length; i++) {
//     final segmentDistance = distanceCalc(
//       points[i - 1].toLatLng(),
//       points[i].toLatLng(),
//     ); // meters
//     splitDistance += segmentDistance;

//     if (splitDistance >= 1000) {
//       final splitEndTime = points[i].timestamp;
//       final duration = splitEndTime.difference(splitStartTime);
//       final pace = duration.inSeconds / 60 / (splitDistance / 1000);

//       splits.add(
//         Split(
//           kilometer: splitCounter,
//           distance: splitDistance,
//           duration: duration,
//           pace: pace,
//         ),
//       );

//       // reset for next split
//       splitCounter++;
//       splitStartTime = splitEndTime;
//       splitDistance = 0.0;
//     }
//   }

//   return splits;
// }

List<Split> calculateSplits(List<RunPoint> points) {
  final distanceCalc = Distance();
  List<Split> splits = [];

  if (points.length < 2) return splits;

  double splitDistance = 0.0;
  int splitCounter = 1;
  DateTime splitStartTime = points.first.timestamp;

  for (int i = 1; i < points.length; i++) {
    final segmentDistance = distanceCalc(
      points[i - 1].toLatLng(),
      points[i].toLatLng(),
    ); // meters
    splitDistance += segmentDistance;

    if (splitDistance >= 100) {
      // now every 100m
      final splitEndTime = points[i].timestamp;
      final duration = splitEndTime.difference(splitStartTime);
      final pace = duration.inSeconds / 60 / (splitDistance / 1000);

      splits.add(
        Split(
          kilometer: splitCounter, // still using this for display
          distance: splitDistance,
          duration: duration,
          pace: pace,
        ),
      );

      // reset for next split
      splitCounter++;
      splitStartTime = splitEndTime;
      splitDistance = 0.0;
    }
  }

  return splits;
}
