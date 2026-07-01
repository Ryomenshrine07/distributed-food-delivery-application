import 'package:customer_app/core/error/failure.dart';
import 'package:customer_app/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Either', () {
    group('Left', () {
      test('isLeft is true', () {
        const either = Left<String, int>('error');
        expect(either.isLeft, isTrue);
        expect(either.isRight, isFalse);
      });

      test('fold calls onLeft', () {
        const either = Left<String, int>('error');
        final result = either.fold((l) => 'left: $l', (r) => 'right: $r');
        expect(result, equals('left: error'));
      });

      test('map does not transform', () {
        const either = Left<String, int>('error');
        final mapped = either.map((r) => r * 2);
        expect(mapped, isA<Left<String, int>>());
        expect((mapped as Left).value, equals('error'));
      });

      test('mapLeft transforms the left value', () {
        const either = Left<String, int>('error');
        final mapped = either.mapLeft((l) => l.length);
        expect(mapped, isA<Left<int, int>>());
        expect((mapped as Left).value, equals(5));
      });

      test('flatMap does not transform', () {
        const either = Left<String, int>('error');
        final result = either.flatMap((r) => Right(r * 2));
        expect(result, isA<Left<String, int>>());
      });

      test('getOrThrow throws StateError', () {
        const either = Left<String, int>('error');
        expect(() => either.getOrThrow(), throwsStateError);
      });

      test('getOrElse returns default value', () {
        const either = Left<String, int>('error');
        expect(either.getOrElse(() => 42), equals(42));
      });

      test('swap becomes Right', () {
        const either = Left<String, int>('error');
        final swapped = either.swap();
        expect(swapped, isA<Right<int, String>>());
        expect((swapped as Right).value, equals('error'));
      });

      test('equality', () {
        const a = Left<String, int>('error');
        const b = Left<String, int>('error');
        const c = Left<String, int>('other');
        expect(a, equals(b));
        expect(a, isNot(equals(c)));
      });
    });

    group('Right', () {
      test('isRight is true', () {
        const either = Right<String, int>(42);
        expect(either.isRight, isTrue);
        expect(either.isLeft, isFalse);
      });

      test('fold calls onRight', () {
        const either = Right<String, int>(42);
        final result = either.fold((l) => 'left: $l', (r) => 'right: $r');
        expect(result, equals('right: 42'));
      });

      test('map transforms the right value', () {
        const either = Right<String, int>(21);
        final mapped = either.map((r) => r * 2);
        expect(mapped, isA<Right<String, int>>());
        expect((mapped as Right).value, equals(42));
      });

      test('mapLeft does not transform', () {
        const either = Right<String, int>(42);
        final mapped = either.mapLeft((l) => l.length);
        expect(mapped, isA<Right<int, int>>());
        expect((mapped as Right).value, equals(42));
      });

      test('flatMap chains the operation', () {
        const either = Right<String, int>(21);
        final result = either.flatMap((r) => Right(r * 2));
        expect(result, isA<Right<String, int>>());
        expect((result as Right).value, equals(42));
      });

      test('flatMap can produce a Left', () {
        const either = Right<String, int>(21);
        final result = either.flatMap<int>((r) => const Left('failed'));
        expect(result, isA<Left<String, int>>());
      });

      test('getOrThrow returns value', () {
        const either = Right<String, int>(42);
        expect(either.getOrThrow(), equals(42));
      });

      test('getOrElse returns the right value', () {
        const either = Right<String, int>(42);
        expect(either.getOrElse(() => 0), equals(42));
      });

      test('swap becomes Left', () {
        const either = Right<String, int>(42);
        final swapped = either.swap();
        expect(swapped, isA<Left<int, String>>());
        expect((swapped as Left).value, equals(42));
      });

      test('equality', () {
        const a = Right<String, int>(42);
        const b = Right<String, int>(42);
        const c = Right<String, int>(99);
        expect(a, equals(b));
        expect(a, isNot(equals(c)));
      });
    });
  });

  group('Result typedef and extensions', () {
    test('Result<T> is Either<Failure, T>', () {
      final Result<int> success = const Right(42);
      final Result<int> failure = const Left(ServerFailure());

      expect(success.isRight, isTrue);
      expect(failure.isLeft, isTrue);
    });

    test('getOrNull returns value on success', () {
      final Result<int> result = const Right(42);
      expect(result.getOrNull(), equals(42));
    });

    test('getOrNull returns null on failure', () {
      final Result<int> result = const Left(TimeoutFailure());
      expect(result.getOrNull(), isNull);
    });

    test('failureOrNull returns failure on Left', () {
      final Result<int> result = const Left(NoConnectionFailure());
      expect(result.failureOrNull, isA<NoConnectionFailure>());
    });

    test('failureOrNull returns null on Right', () {
      final Result<int> result = const Right(42);
      expect(result.failureOrNull, isNull);
    });

    test('onSuccess executes action on Right', () {
      var called = false;
      final Result<int> result = const Right(42);
      result.onSuccess((value) => called = true);
      expect(called, isTrue);
    });

    test('onSuccess does not execute on Left', () {
      var called = false;
      final Result<int> result = const Left(ServerFailure());
      result.onSuccess((value) => called = true);
      expect(called, isFalse);
    });

    test('onFailure executes action on Left', () {
      Failure? captured;
      final Result<int> result = const Left(TimeoutFailure());
      result.onFailure((f) => captured = f);
      expect(captured, isA<TimeoutFailure>());
    });

    test('onFailure does not execute on Right', () {
      var called = false;
      final Result<int> result = const Right(42);
      result.onFailure((_) => called = true);
      expect(called, isFalse);
    });
  });

  group('Failure sealed class hierarchy', () {
    test('pattern matching exhaustive on all subtypes', () {
      final failures = <Failure>[
        const NoConnectionFailure(),
        const TimeoutFailure(),
        const ServerFailure(message: 'Internal error'),
        const ValidationFailure(
            fieldErrors: {'email': ['invalid']}),
        const ConflictFailure(),
        const RateLimitFailure(),
        const InvalidCredentialsFailure(),
        const SessionExpiredFailure(),
        const UnknownFailure(),
      ];

      for (final failure in failures) {
        // Exhaustive switch — compile error if a case is missing.
        final description = switch (failure) {
          NoConnectionFailure() => 'no connection',
          TimeoutFailure() => 'timeout',
          ServerFailure() => 'server',
          ValidationFailure() => 'validation',
          ConflictFailure() => 'conflict',
          RateLimitFailure() => 'rate limit',
          InvalidCredentialsFailure() => 'invalid credentials',
          SessionExpiredFailure() => 'session expired',
          UnknownFailure() => 'unknown',
        };
        expect(description, isNotEmpty);
      }
    });

    test('ValidationFailure carries field errors', () {
      const failure = ValidationFailure(
        fieldErrors: {
          'email': ['already registered'],
          'phone': ['invalid format', 'too short'],
        },
      );
      expect(failure.fieldErrors['email'], contains('already registered'));
      expect(failure.fieldErrors['phone'], hasLength(2));
    });
  });
}
