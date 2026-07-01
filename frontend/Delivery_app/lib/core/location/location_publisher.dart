import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../providers/core_providers.dart';

final locationPublisherProvider = Provider<LocationPublisher>((ref) {
  return LocationPublisher(apiClient: ref.read(apiClientProvider));
});

class LocationPublisher {
  final ApiClient _apiClient;
  StreamSubscription<Position>? _positionStreamSub;
  String? _deliveryPartnerId;

  LocationPublisher({required ApiClient apiClient}) : _apiClient = apiClient;

  void startPublishing(String deliveryPartnerId) {
    if (_positionStreamSub != null) return;
    _deliveryPartnerId = deliveryPartnerId;

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // publish every 10 meters
      ),
    ).listen((Position position) {
      _publishLocation(position);
    });
  }

  void stopPublishing() {
    _positionStreamSub?.cancel();
    _positionStreamSub = null;
    _deliveryPartnerId = null;
  }

  Future<void> _publishLocation(Position position) async {
    if (_deliveryPartnerId == null) return;

    try {
      await _apiClient.postJson(
        '/api/delivery/partners/$_deliveryPartnerId/location',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      );
    } catch (e) {
      debugPrint('Failed to publish location: $e');
    }
  }
}
