// Feature: customer-app, Property 4
//
// Property 4: Authorization header attachment
// For any request path, when a token exists in the store, the Authorization
// header is attached if and only if the path is NOT under `/auth/`.
// Paths under `/auth/` (startsWith('/auth/') or equals '/auth') must NOT have
// the header attached.
//
// **Validates: Requirements 3.3, 25.3**

import 'dart:math';

import 'package:customer_app/core/network/interceptors/auth_interceptor.dart';
import 'package:customer_app/core/network/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Generates a random non-auth path segment (guaranteed to NOT start with /auth/).
String _randomNonAuthPath(Random rng) {
  const segments = [
    '/restaurants',
    '/restaurants/123',
    '/restaurants/search',
    '/orders',
    '/orders/my-orders',
    '/orders/456/cancel',
    '/users/profile',
    '/users/me',
    '/menu/items',
    '/favorites',
    '/addresses',
    '/notifications',
    '/settings',
    '/checkout',
    '/tracking/789',
    '/categories',
    '/health',
    '/api/v1/data',
    '/authentication/verify', // Note: /authentication != /auth/
    '/authorize/token', // Note: /authorize != /auth/
  ];

  // Either pick from known segments or generate a random one.
  if (rng.nextBool()) {
    return segments[rng.nextInt(segments.length)];
  }

  // Generate a random path that does not start with /auth
  final depth = rng.nextInt(3) + 1;
  final parts = <String>[];
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  for (var i = 0; i < depth; i++) {
    final len = rng.nextInt(8) + 1;
    final segment = String.fromCharCodes(
      List.generate(len, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
    );
    parts.add(segment);
  }

  final path = '/${parts.join('/')}';
  // Make sure it doesn't accidentally start with /auth
  if (path.startsWith('/auth/') || path == '/auth') {
    return '/other$path';
  }
  return path;
}

/// Generates a random auth path (guaranteed to start with /auth/ or equal /auth).
String _randomAuthPath(Random rng) {
  const authPaths = [
    '/auth/login/customer',
    '/auth/register/customer',
    '/auth/refresh',
    '/auth/logout',
    '/auth/verify-email',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/otp/send',
    '/auth/otp/verify',
    '/auth',
  ];

  if (rng.nextBool()) {
    return authPaths[rng.nextInt(authPaths.length)];
  }

  // Generate a random sub-path under /auth/
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final len = rng.nextInt(10) + 1;
  final segment = String.fromCharCodes(
    List.generate(len, (_) => chars.codeUnitAt(rng.nextInt(chars.length))),
  );
  return '/auth/$segment';
}

/// A test interceptor that captures the final request options after all
/// preceding interceptors have run.
class _CaptureInterceptor extends Interceptor {
  RequestOptions? captured;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured = options;
    // Reject to prevent actual network call.
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
  group('Property 4: Authorization header attachment', () {
    test(
      'Authorization header is attached iff path is NOT under /auth/ '
      'across ≥100 randomized iterations',
      () async {
        const testToken = 'test-jwt-token-abc123';
        final tokenStore = InMemoryTokenStore();
        await tokenStore.write(testToken);

        final rng = Random(42); // Fixed seed for reproducibility
        const iterations = 120; // Exceeds the ≥100 requirement

        for (var i = 0; i < iterations; i++) {
          // Alternate between auth and non-auth paths to ensure coverage.
          final isAuthPath = rng.nextBool();
          final path =
              isAuthPath ? _randomAuthPath(rng) : _randomNonAuthPath(rng);

          // Create fresh Dio + interceptors for each iteration to avoid state
          // leakage between requests.
          final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8080'));
          final capture = _CaptureInterceptor();

          dio.interceptors.addAll([
            AuthInterceptor(tokenStore: tokenStore, isLocal: true),
            capture,
          ]);

          // Attempt the request — it will be rejected by the capture interceptor.
          try {
            await dio.get(path);
          } on DioException {
            // Expected: the capture interceptor rejects every request.
          }

          final capturedOptions = capture.captured;
          expect(
            capturedOptions,
            isNotNull,
            reason: 'Request for path "$path" was not captured.',
          );

          final hasAuthHeader =
              capturedOptions!.headers.containsKey('Authorization');
          final authHeaderValue = capturedOptions.headers['Authorization'];

          if (isAuthPath) {
            expect(
              hasAuthHeader,
              isFalse,
              reason: 'Auth path "$path" should NOT have Authorization header, '
                  'but found: $authHeaderValue',
            );
          } else {
            expect(
              hasAuthHeader,
              isTrue,
              reason:
                  'Non-auth path "$path" should have Authorization header.',
            );
            expect(
              authHeaderValue,
              equals('Bearer $testToken'),
              reason: 'Non-auth path "$path" should have '
                  '"Bearer $testToken" but got "$authHeaderValue".',
            );
          }
        }
      },
    );
  });
}
