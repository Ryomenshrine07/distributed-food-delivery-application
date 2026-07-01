import '../../../../core/error/result.dart';
import '../entities/session.dart';
import '../entities/user_account.dart';

/// Interface for authentication operations.
///
/// Handles customer registration and login against the backend auth service.
abstract interface class AuthRepository {
  /// Registers a new customer account.
  ///
  /// POST /auth/register/customer
  /// Returns the created [UserAccount] on success (201).
  Future<Result<UserAccount>> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  /// Logs in a customer and establishes a session.
  ///
  /// POST /auth/login/customer
  /// Returns a [Session] with JWT on success (200).
  Future<Result<Session>> loginCustomer({
    required String email,
    required String password,
  });
}
