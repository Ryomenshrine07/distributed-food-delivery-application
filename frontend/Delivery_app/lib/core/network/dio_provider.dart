import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/unauthorized_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'ports.dart';

Dio createDio({
  required TokenStore tokenStore,
  required AuthEventSink authEventSink,
  required LocationPausePort locationPausePort,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        // Bypasses the ngrok browser-warning interstitial so API responses
        // are not replaced with HTML when tunnelling via ngrok.
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(tokenStore),
    LoggingInterceptor(),
    RetryInterceptor(dio, maxRetries: AppConstants.maxRetries),
    UnauthorizedInterceptor(tokenStore, authEventSink, locationPausePort),
    ErrorInterceptor(),
  ]);

  return dio;
}
