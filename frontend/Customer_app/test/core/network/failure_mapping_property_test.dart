// Feature: customer-app, Property 3
//
// Property 3: Failure classification mapping
// For any transport outcome (AppException), assert:
// 1. Exactly one corresponding Failure type is produced (deterministic).
// 2. For ClientException(400), the fieldErrors map is fully preserved in
//    the resulting ValidationFailure (no entries lost).
// 3. Every transport outcome produces a non-null Failure.
//
// **Validates: Requirements 1.6, 23.1, 23.2, 23.3, 23.4, 24.2**

import 'dart:math';

import 'package:customer_app/core/error/app_exception.dart';
import 'package:customer_app/core/error/error_mapper.dart';
import 'package:customer_app/core/error/failure.dart';
import 'package:flutter_test/flutter_test.dart';

/// Generates a random string of [length] from alphanumeric characters.
String _randomString(Random rng, {int maxLength = 20}) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_- ';
  final length = rng.nextInt(maxLength) + 1;
  return String.fromCharCodes(
    List.generate(length, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
  );
}

/// Generates a random field errors map with 1–5 fields, each with 1–3 error messages.
Map<String, List<String>> _randomFieldErrors(Random rng) {
  final fieldCount = rng.nextInt(5) + 1;
  final result = <String, List<String>>{};
  for (var i = 0; i < fieldCount; i++) {
    final fieldName = _randomString(rng, maxLength: 10);
    final errorCount = rng.nextInt(3) + 1;
    final errors = List.generate(errorCount, (_) => _randomString(rng, maxLength: 30));
    result[fieldName] = errors;
  }
  return result;
}

/// Generates a random [AppException] instance.
AppException _randomAppException(Random rng) {
  final type = rng.nextInt(7); // 7 exception types
  return switch (type) {
    0 => const NoConnectionException(),
    1 => const TimeoutException(),
    2 => const UnauthorizedException(),
    3 => ServerException(
        statusCode: 500 + rng.nextInt(100), // 5xx codes
        message: rng.nextBool() ? _randomString(rng) : null,
      ),
    4 => _randomClientException(rng),
    5 => ApiEnvelopeException(message: _randomString(rng)),
    6 => UnknownException(error: rng.nextBool() ? _randomString(rng) : null),
    _ => const UnknownException(), // unreachable
  };
}

/// Generates a random [ClientException] with a random status code.
ClientException _randomClientException(Random rng) {
  // Include the specific codes that have dedicated mappings plus random others.
  final codes = [400, 401, 409, 429, 403, 404, 422, 418, 451];
  final statusCode = codes[rng.nextInt(codes.length)];
  return ClientException(
    statusCode: statusCode,
    message: rng.nextBool() ? _randomString(rng) : null,
    fieldErrors: statusCode == 400 ? _randomFieldErrors(rng) : const {},
  );
}

/// Generates a random [ClientException] specifically with status 400 and non-empty fieldErrors.
ClientException _randomValidationClientException(Random rng) {
  return ClientException(
    statusCode: 400,
    message: rng.nextBool() ? _randomString(rng) : null,
    fieldErrors: _randomFieldErrors(rng),
  );
}

/// Returns the expected [Failure] type for a given [AppException].
Type _expectedFailureType(AppException exception) {
  return switch (exception) {
    NoConnectionException() => NoConnectionFailure,
    TimeoutException() => TimeoutFailure,
    UnauthorizedException() => SessionExpiredFailure,
    ServerException() => ServerFailure,
    ClientException(:final statusCode) => switch (statusCode) {
        400 => ValidationFailure,
        401 => InvalidCredentialsFailure,
        409 => ConflictFailure,
        429 => RateLimitFailure,
        _ => UnknownFailure,
      },
    ApiEnvelopeException() => ServerFailure,
    UnknownException() => UnknownFailure,
  };
}

void main() {
  group('Property 3: Failure classification mapping', () {
    test(
      'Every AppException maps to exactly one Failure type (deterministic) '
      'across ≥100 randomized iterations',
      () {
        final rng = Random(42); // Fixed seed for reproducibility
        const iterations = 120; // Exceeds the ≥100 requirement

        for (var i = 0; i < iterations; i++) {
          final exception = _randomAppException(rng);
          final failure = mapExceptionToFailure(exception);
          final expectedType = _expectedFailureType(exception);

          // Property 1: Exactly one correct Failure type is produced.
          expect(
            failure.runtimeType,
            equals(expectedType),
            reason: 'Iteration $i: $exception should map to $expectedType '
                'but got ${failure.runtimeType}',
          );

          // Property 3: The result is non-null (a non-null Failure is produced).
          // Dart null safety guarantees this via the return type, but we
          // explicitly assert it to document the property.
          expect(
            failure,
            isNotNull,
            reason: 'Iteration $i: $exception produced a null Failure',
          );

          // Verify determinism: calling again with the same exception yields
          // the same result type.
          final failure2 = mapExceptionToFailure(exception);
          expect(
            failure2.runtimeType,
            equals(failure.runtimeType),
            reason: 'Iteration $i: mapping is not deterministic for $exception',
          );
        }
      },
    );

    test(
      'For ClientException(400), fieldErrors map is fully preserved in '
      'ValidationFailure across ≥100 randomized iterations',
      () {
        final rng = Random(99); // Different seed
        const iterations = 120; // Exceeds the ≥100 requirement

        for (var i = 0; i < iterations; i++) {
          final exception = _randomValidationClientException(rng);
          final failure = mapExceptionToFailure(exception);

          // Must produce a ValidationFailure.
          expect(
            failure,
            isA<ValidationFailure>(),
            reason: 'Iteration $i: ClientException(400) should map to '
                'ValidationFailure but got ${failure.runtimeType}',
          );

          final validationFailure = failure as ValidationFailure;

          // Property 2: The fieldErrors map is fully preserved — no entries lost.
          // Same number of fields.
          expect(
            validationFailure.fieldErrors.length,
            equals(exception.fieldErrors.length),
            reason: 'Iteration $i: fieldErrors count mismatch. '
                'Expected ${exception.fieldErrors.length} fields but got '
                '${validationFailure.fieldErrors.length}',
          );

          // Every field key exists in the result.
          for (final key in exception.fieldErrors.keys) {
            expect(
              validationFailure.fieldErrors.containsKey(key),
              isTrue,
              reason: 'Iteration $i: field "$key" was lost in mapping',
            );

            // Every error message for that field is preserved.
            expect(
              validationFailure.fieldErrors[key],
              equals(exception.fieldErrors[key]),
              reason: 'Iteration $i: error messages for field "$key" differ. '
                  'Expected: ${exception.fieldErrors[key]}, '
                  'Got: ${validationFailure.fieldErrors[key]}',
            );
          }

          // No extra fields were added.
          for (final key in validationFailure.fieldErrors.keys) {
            expect(
              exception.fieldErrors.containsKey(key),
              isTrue,
              reason:
                  'Iteration $i: unexpected field "$key" appeared in result',
            );
          }
        }
      },
    );

    test(
      'Every transport outcome produces a non-null Failure '
      'across ≥100 randomized iterations',
      () {
        final rng = Random(7); // Another seed
        const iterations = 120; // Exceeds the ≥100 requirement

        for (var i = 0; i < iterations; i++) {
          final exception = _randomAppException(rng);
          final failure = mapExceptionToFailure(exception);

          // Every exception maps to a Failure (non-null, is a Failure instance).
          expect(
            failure,
            isA<Failure>(),
            reason: 'Iteration $i: $exception did not produce a Failure',
          );

          // The failure has a non-empty message (all Failure subclasses provide
          // a default or forwarded message).
          expect(
            failure.message,
            isNotEmpty,
            reason: 'Iteration $i: $exception produced a Failure with an '
                'empty message: ${failure.runtimeType}',
          );
        }
      },
    );
  });
}
