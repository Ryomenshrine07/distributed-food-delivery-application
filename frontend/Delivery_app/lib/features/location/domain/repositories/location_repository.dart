import '../../../../core/error/result.dart';
import 'package:geolocator/geolocator.dart';

abstract class LocationRepository {
  /// Stream of location updates when the app is in the foreground
  Stream<Position> getForegroundLocationStream();
  
  /// Get current location (one-shot)
  Future<Result<Position>> getCurrentLocation();

  /// Submit the location heartbeat to the backend
  Future<Result<void>> submitHeartbeat(double latitude, double longitude);
}
