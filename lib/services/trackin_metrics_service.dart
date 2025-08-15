import 'dart:math';
import 'package:trail_sync/models/location_point.dart';

class TrackingMetricsService {
  double calculateTotalDistance(List<LocationPoint> points) {
    if (points.length < 2) return 0;
    double total = 0;
    for (var i = 0; i < points.length - 1; i++) {
      total += _haversine(points[i], points[i + 1]);
    }
    return total;
  }

  double? calculateAveragePace(List<LocationPoint> points, Duration elapsed) {
    final km = calculateTotalDistance(points) / 1000;
    if (km == 0) return null;
    return elapsed.inSeconds / 60 / km;
  }

  double _haversine(LocationPoint p1, LocationPoint p2) {
    const R = 6371000;
    final lat1 = p1.lat * pi / 180;
    final lat2 = p2.lat * pi / 180;
    final dLat = (p2.lat - p1.lat) * pi / 180;
    final dLon = (p2.lng - p1.lng) * pi / 180;

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }
}
