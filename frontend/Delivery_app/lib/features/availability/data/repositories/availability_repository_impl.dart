import '../../../../core/error/result.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/network/api_client.dart';
import '../../../authentication/domain/repositories/session_repository.dart';
import '../../domain/repositories/availability_repository.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final ApiClient _apiClient;
  final SessionRepository _sessionRepository;

  AvailabilityRepositoryImpl(this._apiClient, this._sessionRepository);

  @override
  Future<Result<void>> goOnline() async {
    final session = _sessionRepository.currentSession;
    if (session == null || session.isExpired) {
      return Left(SessionExpiredFailure());
    }

    try {
      await _apiClient.postVoid('/api/delivery/partners/${session.partnerId}/online');
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }

  @override
  Future<Result<void>> goOffline() async {
    final session = _sessionRepository.currentSession;
    if (session == null || session.isExpired) {
      return Left(SessionExpiredFailure());
    }

    try {
      await _apiClient.postVoid('/api/delivery/partners/${session.partnerId}/offline');
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }
}
