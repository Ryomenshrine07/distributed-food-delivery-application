import '../../../../core/error/result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<void>> login(String email, String password);
  Future<Result<User>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String vehicleType,
    required String licenseNumber,
  });
  Future<Result<void>> logout();
}
