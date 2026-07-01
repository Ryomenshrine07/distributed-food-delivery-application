import 'package:geolocator/geolocator.dart';
import '../../../../core/error/result.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../../../authentication/domain/repositories/session_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../utils/coordinate_validator.dart';

class LocationRepositoryImpl implements LocationRepository {
  final ApiClient _apiClient;
  final SessionRepository _sessionRepository;

  LocationRepositoryImpl(this._apiClient, this._sessionRepository);

  @override
  Stream<Position> getForegroundLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    );
  }

  @override
  Future<Result<Position>> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return Right(position);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }

  @override
  Future<Result<void>> submitHeartbeat(double latitude, double longitude) async {
    final session = _sessionRepository.currentSession;
    if (session == null || session.isExpired) {
      return Left(SessionExpiredFailure());
    }

    if (!CoordinateValidator.isValid(latitude, longitude)) {
      return Left(ValidationFailure({'location': 'Invalid coordinates'}));
    }

    try {
      await _apiClient.postVoid(
        '/api/delivery/partners/${session.partnerId}/location',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }
}
