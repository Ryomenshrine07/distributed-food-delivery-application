import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/core/error/failure.dart';
import 'package:delivery_app/core/error/result.dart';
import 'package:delivery_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:delivery_app/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:delivery_app/features/authentication/presentation/providers/auth_providers.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthController', () {
    late MockAuthRepository mockAuthRepo;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepo = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('login success updates state to data', () async {
      when(() => mockAuthRepo.login('test@example.com', 'password'))
          .thenAnswer((_) async => const Right(null));

      final controller = container.read(authControllerProvider.notifier);
      
      final result = await controller.login('test@example.com', 'password');
      
      expect(result, isNull);
      expect(container.read(authControllerProvider), const AsyncData<void>(null));
      verify(() => mockAuthRepo.login('test@example.com', 'password')).called(1);
    });

    test('login failure updates state to error and returns failure', () async {
      const failure = InvalidCredentialsFailure();
      when(() => mockAuthRepo.login('test@example.com', 'wrong'))
          .thenAnswer((_) async => const Left(failure));

      final controller = container.read(authControllerProvider.notifier);
      
      final result = await controller.login('test@example.com', 'wrong');
      
      expect(result, failure);
      expect(container.read(authControllerProvider).hasError, true);
      verify(() => mockAuthRepo.login('test@example.com', 'wrong')).called(1);
    });
  });
}
