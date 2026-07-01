import '../entities/route_info.dart';

abstract class NavigationRepository {
  /// Get route from origin to destination.
  /// Falls back to Haversine straight-line if Directions API unavailable.
  Future<RouteInfo> getRoute(LatLng origin, LatLng destination);

  /// Launch external navigation app (Google Maps / Apple Maps).
  Future<bool> launchExternalNav(LatLng destination, String label);
}
