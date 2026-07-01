abstract class LocationPermissionHandler {
  Future<bool> hasForegroundPermission();
  Future<bool> hasBackgroundPermission();
  Future<bool> requestForegroundPermission();
  Future<bool> requestBackgroundPermission();
  Future<bool> isGpsEnabled();
}
