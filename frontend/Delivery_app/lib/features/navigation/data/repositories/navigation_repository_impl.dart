import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/route_info.dart';
import '../../domain/repositories/navigation_repository.dart';

class NavigationRepositoryImpl implements NavigationRepository {
  @override
  Future<RouteInfo> getRoute(LatLng origin, LatLng destination) async {
    // Fallback: Haversine straight-line distance with estimated time (30 km/h avg in city)
    final distanceKm = origin.distanceTo(destination);
    final estimatedMinutes = (distanceKm / 30) * 60; // 30km/h average

    return RouteInfo(
      distanceKm: distanceKm,
      estimatedTime: Duration(minutes: estimatedMinutes.ceil()),
      polylinePoints: [origin, destination], // Straight line
    );
  }

  @override
  Future<bool> launchExternalNav(LatLng destination, String label) async {
    final encodedLabel = Uri.encodeComponent(label);
    Uri uri;

    if (!kIsWeb && Platform.isIOS) {
      // Try Apple Maps first
      uri = Uri.parse(
        'https://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}&dirflg=d',
      );
    } else {
      // Google Maps
      uri = Uri.parse(
        'google.navigation:q=${destination.latitude},${destination.longitude}&mode=d',
      );
    }

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    // Fallback: browser Google Maps URL
    final fallbackUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}&travelmode=driving',
    );
    return await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
  }
}
