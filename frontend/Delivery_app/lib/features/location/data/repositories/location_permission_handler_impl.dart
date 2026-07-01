import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/repositories/location_permission_handler.dart';

class LocationPermissionHandlerImpl implements LocationPermissionHandler {
  @override
  Future<bool> hasForegroundPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted || status.isLimited;
  }

  @override
  Future<bool> hasBackgroundPermission() async {
    final status = await Permission.locationAlways.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestForegroundPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted || status.isLimited;
  }

  @override
  Future<bool> requestBackgroundPermission() async {
    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  @override
  Future<bool> isGpsEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
