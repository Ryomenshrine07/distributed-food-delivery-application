import '../../../core/error/app_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/error/result.dart';
import '../../session/session_repository_impl.dart';
import '../data/auth_remote_data_source.dart';
import '../data/mappers/auth_mapper.dart';
import '../domain/entities/session.dart';
import '../domain/entities/user_account.dart';
import '../domain/repositories/auth_repository.dart';

/// Concrete implementation of [AuthRepository].
///
/// Maps API responses to domain entities and handles error classification
/// via [mapExceptionToFailure]. On login success, persists the session
/// via [SessionRepositoryImpl].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required SessionRepositoryImpl sessionRepository,
  })  : _dataSource = dataSource,
        _sessionRepo = sessionRepository;

  final AuthRemoteDataSource _dataSource;
  final SessionRepositoryImpl _sessionRepo;

  @override
  Future<Result<UserAccount>> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final dto = await _dataSource.registerCustomer(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );
      return Right(AuthMapper.userAccountFromDto(dto));
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(mapExceptionToFailure(UnknownException(error: e)));
    }
  }

  @override
  Future<Result<Session>> loginCustomer({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _dataSource.loginCustomer(
        email: email,
        password: password,
      );
      final session = AuthMapper.sessionFromDto(dto);
      await _sessionRepo.persist(session);
      return Right(session);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(mapExceptionToFailure(UnknownException(error: e)));
    }
  }
}
