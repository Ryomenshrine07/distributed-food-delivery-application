// Feature: customer-app, Property 22
//
// Property 22: Sensitive value redaction in logs
// For any log record embedding a JWT or password, assert the logged output
// never contains the token/password value.
// - Authorization header values are replaced with ***REDACTED***
// - Body fields named password, token, refreshToken, refresh_token are
//   replaced with ***REDACTED***
// - The actual sensitive string NEVER appears in the logged output
//
// **Validates: Requirements 25.2**

import 'dart:math';

import 'package:customer_app/core/network/interceptors/logging_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Generates a random JWT-like token string.
String _randomJwt(Random rng) {
  const base64Chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';

  String randomBase64Segment(int length) {
    return String.fromCharCodes(
      List.generate(
        length,
        (_) => base64Chars.codeUnitAt(rng.nextInt(base64Chars.length)),
      ),
    );
  }

  // JWT format: header.payload.signature
  final header = randomBase64Segment(rng.nextInt(20) + 10);
  final payload = randomBase64Segment(rng.nextInt(80) + 20);
  final signature = randomBase64Segment(rng.nextInt(40) + 20);
  return '$header.$payload.$signature';
}

/// Generates a random password string of variable length.
String _randomPassword(Random rng) {
  const chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
      r'!@#$%^&*()_+-=[]{}|;:,.<>?';
  final length = rng.nextInt(50) + 8; // 8-57 characters
  return String.fromCharCodes(
    List.generate(length, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
  );
}

/// Generates a random non-sensitive field name.
String _randomFieldName(Random rng) {
  const fields = [
    'email',
    'fullName',
    'phone',
    'city',
    'address',
    'quantity',
    'restaurantId',
    'orderId',
    'description',
    'name',
    'category',
    'latitude',
    'longitude',
  ];
  return fields[rng.nextInt(fields.length)];
}

/// Generates a random non-sensitive value.
String _randomValue(Random rng) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final length = rng.nextInt(20) + 3;
  return String.fromCharCodes(
    List.generate(length, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
  );
}

/// A capture interceptor placed after the LoggingInterceptor to prevent
/// actual network calls.
class _CaptureInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: options,
        type: DioExceptionType.cancel,
        message: 'Captured for testing',
      ),
    );
  }
}

void main() {
  group('Property 22: Sensitive value redaction in logs', () {
    test(
      'Authorization header value never appears in logged output '
      'across ≥100 randomized iterations',
      () async {
        final rng = Random(42); // Fixed seed for reproducibility
        const iterations = 120; // Exceeds the ≥100 requirement

        for (var i = 0; i < iterations; i++) {
          final logOutput = <String>[];
          final interceptor = LoggingInterceptor(
            logSink: (message, {name = 'HTTP'}) => logOutput.add(message),
          );

          final token = _randomJwt(rng);

          // Build a Dio instance with the logging interceptor and a capture
          // interceptor that stops the request from going to the network.
          final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
          dio.interceptors.addAll([interceptor, _CaptureInterceptor()]);

          // Issue a request with the Authorization header containing the token.
          try {
            await dio.get(
              '/restaurants',
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                  'X-Request-Id': _randomValue(rng),
                },
              ),
            );
          } on DioException {
            // Expected: the capture interceptor rejects every request.
          }

          // Assert: At least one log message was captured.
          expect(
            logOutput.isNotEmpty,
            isTrue,
            reason: 'Iteration $i: No log output was captured.',
          );

          final loggedText = logOutput.join('\n');

          // Assert: The logged output must NOT contain the actual token value.
          expect(
            loggedText.contains(token),
            isFalse,
            reason: 'Iteration $i: Logged output contains the raw JWT token '
                '"${token.substring(0, 20)}...". '
                'Sensitive values must be redacted.',
          );

          // Assert: The redacted placeholder IS present.
          expect(
            loggedText.contains(LoggingInterceptor.redacted),
            isTrue,
            reason: 'Iteration $i: Logged output does not contain the '
                '${LoggingInterceptor.redacted} placeholder for the '
                'Authorization header.',
          );
        }
      },
    );

    test(
      'Password/token body field values never appear in logged output '
      'across ≥100 randomized iterations',
      () async {
        final rng = Random(99); // Different seed
        const iterations = 120; // Exceeds the ≥100 requirement

        // Sensitive field names to test
        const sensitiveFields = [
          'password',
          'token',
          'refreshToken',
          'refresh_token',
        ];

        for (var i = 0; i < iterations; i++) {
          final logOutput = <String>[];
          final interceptor = LoggingInterceptor(
            logSink: (message, {name = 'HTTP'}) => logOutput.add(message),
          );

          final sensitiveValue = _randomPassword(rng);
          final fieldName = sensitiveFields[rng.nextInt(sensitiveFields.length)];

          // Build a request body containing the sensitive field alongside
          // non-sensitive fields.
          final body = <String, dynamic>{
            fieldName: sensitiveValue,
            _randomFieldName(rng): _randomValue(rng),
            'email': 'user${rng.nextInt(999)}@example.com',
          };

          final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
          dio.interceptors.addAll([interceptor, _CaptureInterceptor()]);

          try {
            await dio.post(
              '/auth/login/customer',
              data: body,
              options: Options(
                headers: {'Content-Type': 'application/json'},
              ),
            );
          } on DioException {
            // Expected: the capture interceptor rejects every request.
          }

          // Assert: At least one log message was captured.
          expect(
            logOutput.isNotEmpty,
            isTrue,
            reason: 'Iteration $i: No log output was captured.',
          );

          final loggedText = logOutput.join('\n');

          // Assert: The logged output must NOT contain the actual sensitive value.
          expect(
            loggedText.contains(sensitiveValue),
            isFalse,
            reason: 'Iteration $i: Logged output contains the raw sensitive '
                'value for field "$fieldName". '
                'Sensitive body fields must be redacted.',
          );

          // Assert: The redacted placeholder IS present for the sensitive field.
          expect(
            loggedText.contains(LoggingInterceptor.redacted),
            isTrue,
            reason: 'Iteration $i: Logged output does not contain the '
                '${LoggingInterceptor.redacted} placeholder for body '
                'field "$fieldName".',
          );
        }
      },
    );

    test(
      'Nested body sensitive fields are redacted in logged output '
      'across ≥100 randomized iterations',
      () async {
        final rng = Random(7); // Another seed
        const iterations = 120; // Exceeds the ≥100 requirement

        for (var i = 0; i < iterations; i++) {
          final logOutput = <String>[];
          final interceptor = LoggingInterceptor(
            logSink: (message, {name = 'HTTP'}) => logOutput.add(message),
          );

          final sensitiveValue = _randomPassword(rng);

          // Build a request body with a nested structure containing sensitive
          // fields at various depths.
          final body = <String, dynamic>{
            'email': 'user${rng.nextInt(999)}@example.com',
            'credentials': <String, dynamic>{
              'password': sensitiveValue,
              'username': _randomValue(rng),
            },
          };

          final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
          dio.interceptors.addAll([interceptor, _CaptureInterceptor()]);

          try {
            await dio.post(
              '/auth/register/customer',
              data: body,
              options: Options(
                headers: {'Content-Type': 'application/json'},
              ),
            );
          } on DioException {
            // Expected: the capture interceptor rejects every request.
          }

          expect(
            logOutput.isNotEmpty,
            isTrue,
            reason: 'Iteration $i: No log output was captured.',
          );

          final loggedText = logOutput.join('\n');

          // Assert: The actual password value NEVER appears in logged output.
          expect(
            loggedText.contains(sensitiveValue),
            isFalse,
            reason: 'Iteration $i: Logged output contains the raw password '
                'value from a nested body field. '
                'Nested sensitive values must also be redacted.',
          );

          // Assert: The redacted placeholder IS present.
          expect(
            loggedText.contains(LoggingInterceptor.redacted),
            isTrue,
            reason: 'Iteration $i: Logged output does not contain the '
                '${LoggingInterceptor.redacted} placeholder for nested '
                'password field.',
          );
        }
      },
    );

    test(
      'Response body sensitive (JWT/token) values never appear in logged '
      'output across ≥100 randomized iterations',
      () {
        final rng = Random(2024); // Distinct seed for reproducibility
        const iterations = 120; // Exceeds the ≥100 requirement

        // Sensitive response field names that may carry a JWT.
        const sensitiveFields = [
          'token',
          'refreshToken',
          'refresh_token',
        ];

        for (var i = 0; i < iterations; i++) {
          final logOutput = <String>[];
          final interceptor = LoggingInterceptor(
            logSink: (message, {name = 'HTTP'}) => logOutput.add(message),
          );

          final jwt = _randomJwt(rng);
          final fieldName =
              sensitiveFields[rng.nextInt(sensitiveFields.length)];

          // A login-style response body carrying the JWT alongside
          // non-sensitive identity fields. The JWT first reaches the client
          // through this response, so redaction here is security-critical.
          final responseBody = <String, dynamic>{
            fieldName: jwt,
            'userId': rng.nextInt(99999),
            'fullName': _randomValue(rng),
            'email': 'user${rng.nextInt(999)}@example.com',
            'role': 'CUSTOMER',
          };

          final response = Response<dynamic>(
            requestOptions: RequestOptions(
              path: '/auth/login/customer',
              method: 'POST',
            ),
            statusCode: 200,
            data: responseBody,
          );

          // Drive the response path of the interceptor directly. onResponse
          // logs synchronously before forwarding via handler.next.
          interceptor.onResponse(response, ResponseInterceptorHandler());

          // Assert: At least one log message was captured.
          expect(
            logOutput.isNotEmpty,
            isTrue,
            reason: 'Iteration $i: No log output was captured.',
          );

          final loggedText = logOutput.join('\n');

          // Assert: The raw JWT must NOT appear in the logged response output.
          expect(
            loggedText.contains(jwt),
            isFalse,
            reason: 'Iteration $i: Logged response output contains the raw '
                'JWT for field "$fieldName". '
                'Response sensitive values must be redacted.',
          );

          // Assert: The redacted placeholder IS present for the sensitive field.
          expect(
            loggedText.contains(LoggingInterceptor.redacted),
            isTrue,
            reason: 'Iteration $i: Logged response output does not contain the '
                '${LoggingInterceptor.redacted} placeholder for response '
                'field "$fieldName".',
          );
        }
      },
    );
  });
}
