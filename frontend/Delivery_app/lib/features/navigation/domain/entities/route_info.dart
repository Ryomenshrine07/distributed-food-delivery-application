import 'dart:math';

class RouteInfo {
  final double distanceKm;
  final Duration estimatedTime;
  final List<LatLng> polylinePoints;

  const RouteInfo({
    required this.distanceKm,
    required this.estimatedTime,
    this.polylinePoints = const [],
  });
}

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  /// Haversine distance in km
  double distanceTo(LatLng other) {
    const R = 6371.0; // Earth radius in km
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(other.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
