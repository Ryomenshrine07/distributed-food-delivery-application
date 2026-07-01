import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return GeocodingService();
});

/// Resolves a free-form delivery address into real coordinates using the
/// Google Geocoding API, so the order's delivery location matches what the
/// customer actually typed (instead of a hardcoded default).
class GeocodingService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';
  final Dio _dio;

  GeocodingService({Dio? dio}) : _dio = dio ?? Dio();

  // Provided at build/run time via --dart-define=MAPS_API_KEY=... (see local setup).
  // Do NOT hardcode the real key here — this file is committed to a public repo.
  static const String _apiKey = String.fromEnvironment('MAPS_API_KEY');

  /// Geocodes [address] to a [LatLng], optionally biasing results to a region
  /// (e.g. a city/country) for more accurate matches. Returns null if the
  /// address can't be resolved or the request fails.
  Future<LatLng?> geocode(String address, {String? regionBias}) async {
    final trimmed = address.trim();
    if (trimmed.isEmpty) return null;
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'address': trimmed,
          if (regionBias != null && regionBias.isNotEmpty)
            'components': 'locality:$regionBias',
          'key': _apiKey,
        },
      );

      if (response.data['status'] == 'OK') {
        final results = response.data['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          final loc = results.first['geometry']['location'];
          return LatLng(
            (loc['lat'] as num).toDouble(),
            (loc['lng'] as num).toDouble(),
          );
        }
      } else {
        debugPrint('Geocoding failed: ${response.data['status']}');
      }
    } catch (e) {
      debugPrint('Error geocoding address: $e');
    }
    return null;
  }

  /// Reverse-geocodes coordinates into a human-readable address (used to label
  /// the delivery point after picking it from GPS). Returns null on failure.
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': _apiKey,
        },
      );
      if (response.data['status'] == 'OK') {
        final results = response.data['results'] as List<dynamic>;
        if (results.isNotEmpty) {
          return results.first['formatted_address'] as String?;
        }
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
    }
    return null;
  }
}
