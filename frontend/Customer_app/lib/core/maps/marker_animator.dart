import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerAnimator {
  final AnimationController controller;
  late Animation<double> _animation;
  LatLng _startPosition;
  LatLng _endPosition;

  MarkerAnimator({
    required this.controller,
    required LatLng initialPosition,
  })  : _startPosition = initialPosition,
        _endPosition = initialPosition {
    _animation = Tween<double>(begin: 0, end: 1).animate(controller);
  }

  void animateTo(LatLng newPosition) {
    _startPosition = currentValue;
    _endPosition = newPosition;
    controller.reset();
    controller.forward();
  }

  LatLng get currentValue {
    if (!controller.isAnimating) return _endPosition;
    final value = _animation.value;
    final lat = _startPosition.latitude + (_endPosition.latitude - _startPosition.latitude) * value;
    final lng = _startPosition.longitude + (_endPosition.longitude - _startPosition.longitude) * value;
    return LatLng(lat, lng);
  }

  /// Calculates the bearing between start and end position for marker rotation
  double get bearing {
    final lat1 = _startPosition.latitude * pi / 180;
    final lng1 = _startPosition.longitude * pi / 180;
    final lat2 = _endPosition.latitude * pi / 180;
    final lng2 = _endPosition.longitude * pi / 180;

    final dLon = lng2 - lng1;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    var brng = atan2(y, x);
    brng = brng * 180 / pi;
    brng = (brng + 360) % 360;

    return brng;
  }
}
