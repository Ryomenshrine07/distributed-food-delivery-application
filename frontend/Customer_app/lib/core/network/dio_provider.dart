import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import 'auth_event_sink.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/unauthorized_interceptor.dart';
import 'token_store.dart';

/// Builds and provides the singleton [Dio] instance for the app.
///
/// Interceptor order: Auth → Logging → Retry → Unauthorized(401 seam) → Error
///
/// Dependencies:
/// - [TokenStore] — read/clear the JWT (in-memory default; replaced by
///   secure-storage in task 5).
/// - [AuthEventSink] — emit `SessionExpired` (no-op default; replaced by
///   session layer in task 8).
/// - [isLocal] — when `false`, the auth interceptor forces HTTPS.
class DioProvider {
  DioProvider._();

  static Dio? _instance;

  /// Returns the singleton [Dio] instance configured with base options and
  /// the full interceptor chain.
  ///
  /// Call [reset] in tests to clear the singleton.
  static Dio instance({
    TokenStore? tokenStore,
    AuthEventSink? authEventSink,
    bool isLocal = true,
  }) {
    if (_instance != null) return _instance!;

    final store = tokenStore ?? InMemoryTokenStore();
    final eventSink = authEventSink ?? NoOpAuthEventSink();

    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor order: Auth → Logging → Retry → Unauthorized → Error
    dio.interceptors.addAll([
      AuthInterceptor(tokenStore: store, isLocal: isLocal),
      LoggingInterceptor(),
      RetryInterceptor(dio: dio),
      UnauthorizedInterceptor(tokenStore: store, authEventSink: eventSink),
      ErrorInterceptor(),
    ]);

    _instance = dio;
    return dio;
  }

  /// Creates a fresh [Dio] instance without caching (useful for tests and
  /// custom configurations).
  static Dio create({
    TokenStore? tokenStore,
    AuthEventSink? authEventSink,
    bool isLocal = true,
    String? baseUrl,
  }) {
    final store = tokenStore ?? InMemoryTokenStore();
    final eventSink = authEventSink ?? NoOpAuthEventSink();

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Bypasses the ngrok browser-warning interstitial so API responses
          // are not replaced with HTML when tunnelling via ngrok.
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(tokenStore: store, isLocal: isLocal),
      LoggingInterceptor(),
      RetryInterceptor(dio: dio),
      UnauthorizedInterceptor(tokenStore: store, authEventSink: eventSink),
      ErrorInterceptor(),
    ]);

    return dio;
  }

  /// Resets the singleton instance. **Test-only.**
  static void reset() {
    _instance?.close();
    _instance = null;
  }
}
