import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/error/failure.dart';
import '../providers/auth_providers.dart';
import '../../../assignment/presentation/providers/assignment_providers.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // No initial state logic needed
  }

  Future<Failure?> login(String email, String password) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.login(email, password);
    
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
      (_) {
        state = const AsyncData(null);
        return null;
      },
    );
  }

  Future<Failure?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String vehicleType,
    required String licenseNumber,
  }) async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.register(
      email: email,
      password: password,
      name: name,
      phone: phone,
      vehicleType: vehicleType,
      licenseNumber: licenseNumber,
    );

    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure;
      },
      (_) {
        state = const AsyncData(null);
        return null;
      },
    );
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.logout();
    
    // Clear any cached assignments to prevent ghost assignments on re-login
    await ref.read(assignmentRepositoryProvider).clearActiveAssignment();
    
    state = const AsyncData(null);
  }
}
