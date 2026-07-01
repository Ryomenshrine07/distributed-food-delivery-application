import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/failure.dart';
import '../../../core/network/api_client.dart';
import '../../session/session_repository_impl.dart';
import '../data/auth_remote_data_source.dart';
import '../data/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';

part 'auth_controller.g.dart';

/// Provides the [AuthRepository] bound to its concrete implementation.
@riverpod
AuthRepository authRepository(Ref ref) {
  final apiClient = ApiClient();
  final dataSource = AuthRemoteDataSource(apiClient: apiClient);
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return AuthRepositoryImpl(
    dataSource: dataSource,
    sessionRepository: sessionRepo,
  );
}

/// State for the authentication controller.
@immutable
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.failure,
    this.registrationSuccess = false,
  });

  final bool isLoading;
  final Failure? failure;
  final bool registrationSuccess;

  AuthState copyWith({
    bool? isLoading,
    Failure? failure,
    bool? registrationSuccess,
    bool clearFailure = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : (failure ?? this.failure),
      registrationSuccess: registrationSuccess ?? this.registrationSuccess,
    );
  }
}

/// Controller for login and registration flows.
///
/// Manages form submission state, loading indicators, and error display.
/// Login success is handled by the session repo → router redirect chain.
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState();

  /// Submits the registration form.
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (state.isLoading) return; // Prevent duplicate submissions.
    state = state.copyWith(isLoading: true, clearFailure: true);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.registerCustomer(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        failure: failure,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        registrationSuccess: true,
      ),
    );
  }

  /// Submits the login form.
  ///
  /// On success, the session is persisted and the router automatically
  /// redirects to `/home` via the session stream.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return; // Prevent duplicate submissions.
    state = state.copyWith(isLoading: true, clearFailure: true);

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.loginCustomer(
      email: email,
      password: password,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        failure: failure,
      ),
      (_) => state = state.copyWith(isLoading: false),
    );
  }

  /// Clears any displayed failure.
  void clearFailure() {
    state = state.copyWith(clearFailure: true);
  }

  /// Triggers logout via the session repository.
  Future<void> logout() async {
    final sessionRepo = ref.read(sessionRepositoryProvider);
    await sessionRepo.clear();
  }
}
