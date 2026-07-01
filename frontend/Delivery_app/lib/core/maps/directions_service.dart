import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final directionsServiceProvider = Provider<DirectionsService>((ref) {
  return DirectionsService();
});

class DirectionsInfo {
  final List<LatLng> polylinePoints;
  final String totalDistance;
  final String totalDuration;

  DirectionsInfo({
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });
}

class DirectionsService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  final Dio _dio;

  DirectionsService({Dio? dio}) : _dio = dio ?? Dio();

  // Provided at build/run time via --dart-define=MAPS_API_KEY=... (see local setup).
  // Do NOT hardcode the real key here — this file is committed to a public repo.
  static const String _apiKey = String.fromEnvironment('MAPS_API_KEY');

  Future<DirectionsInfo?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': _apiKey,
        },
      );

      if (response.data['status'] == 'OK') {
        final route = response.data['routes'][0];
        final leg = route['legs'][0];

        final distance = leg['distance']['text'] as String;
        final duration = leg['duration']['text'] as String;

        final pointsString = route['overview_polyline']['points'] as String;
        final polylinePoints = PolylinePoints()
            .decodePolyline(pointsString)
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();

        return DirectionsInfo(
          polylinePoints: polylinePoints,
          totalDistance: distance,
          totalDuration: duration,
        );
      }
    } catch (e) {
      debugPrint('Error fetching directions: $e');
    }
    return null;
  }
}
