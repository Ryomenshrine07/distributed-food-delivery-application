import '../../../../core/error/result.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../dtos/auth_response_dto.dart';
import '../dtos/user_response_dto.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SessionRepository _sessionRepository;

  AuthRepositoryImpl(this._apiClient, this._sessionRepository);

  @override
  Future<Result<void>> login(String email, String password) async {
    try {
      final response = await _apiClient.postJson(
        '/auth/login/delivery-person',
        data: {'email': email, 'password': password},
      );
      final dto = AuthResponseDto.fromJson(response.data['data'] ?? response.data);
      await _sessionRepository.saveSession(dto.token);
      return const Right(null);
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }

  @override
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String vehicleType,
    required String licenseNumber,
  }) async {
    try {
      final response = await _apiClient.postJson(
        '/auth/register/delivery',
        data: {
          'email': email,
          'password': password,
          'fullName': name,
          'phone': phone,
          'vehicleType': vehicleType,
          'licenseNumber': licenseNumber,
        },
      );
      final dto = UserResponseDto.fromJson(response.data['data'] ?? response.data);
      return Right(dto.toDomain());
    } catch (e) {
      return Left(ErrorMapper.mapToFailure(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    final session = _sessionRepository.currentSession;
    if (session != null && !session.isExpired) {
      try {
        await _apiClient.postVoid('/api/delivery/partners/${session.partnerId}/offline');
      } catch (_) {
        // Best effort
      }
    }
    
    await _sessionRepository.clearSession();
    return const Right(null);
  }
}
