import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import 'dtos/auth_response_dto.dart';
import 'dtos/user_response_dto.dart';

/// Remote data source for the authentication endpoints.
///
/// Communicates with `POST /auth/register/customer` and
/// `POST /auth/login/customer` via [ApiClient].
class AuthRemoteDataSource {
  AuthRemoteDataSource({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  /// Registers a new customer.
  ///
  /// Returns the [UserResponseDto] on 201. Throws [DioException] on error
  /// (409 duplicate, 429 rate limit, 400 validation, etc.).
  Future<UserResponseDto> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    return _api.postJson(
      '/auth/register/customer',
      body: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
      },
      fromJsonT: (json) =>
          UserResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Logs in a customer.
  ///
  /// Returns the [AuthResponseDto] on 200. Throws [DioException] on error
  /// (401 invalid credentials, 429 rate limit, etc.).
  Future<AuthResponseDto> loginCustomer({
    required String email,
    required String password,
  }) async {
    return _api.postJson(
      '/auth/login/customer',
      body: {
        'email': email,
        'password': password,
      },
      fromJsonT: (json) =>
          AuthResponseDto.fromJson(json as Map<String, dynamic>),
    );
  }
}
