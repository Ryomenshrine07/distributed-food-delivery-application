import 'dart:math' as math;

class HeartbeatThrottle {
  final double thresholdMeters;
  double? _lastLat;
  double? _lastLng;

  HeartbeatThrottle({this.thresholdMeters = 15.0});

  bool shouldSendHeartbeat(double lat, double lng) {
    if (_lastLat == null || _lastLng == null) {
      return true;
    }

    final distance = _calculateDistance(_lastLat!, _lastLng!, lat, lng);
    return distance >= thresholdMeters;
  }

  void onHeartbeatSent(double lat, double lng) {
    _lastLat = lat;
    _lastLng = lng;
  }

  void reset() {
    _lastLat = null;
    _lastLng = null;
  }

  // Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // in meters
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }
}
