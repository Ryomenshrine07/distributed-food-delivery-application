import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

/// Retries idempotent GET requests on timeout or transient server errors (5xx)
/// using bounded exponential backoff.
///
/// Behaviour:
/// - Only retries GET requests (idempotent).
/// - Only retries on timeout ([DioExceptionType.connectionTimeout],
///   [DioExceptionType.receiveTimeout], [DioExceptionType.sendTimeout])
///   or 5xx server errors.
/// - Never retries 4xx client errors.
/// - Maximum 3 retry attempts.
/// - Backoff: `min(baseDelay * 2^attempt, maxDelay)` with optional jitter.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 8),
  }) : _dio = dio;

  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;
    final retryCount = (options.extra['_retryCount'] as int?) ?? 0;

    if (retryCount >= maxRetries) {
      handler.next(err);
      return;
    }

    options.extra['_retryCount'] = retryCount + 1;

    final delay = _computeDelay(retryCount);
    await Future<void>.delayed(delay);

    try {
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err) {
    // Only retry GET requests (idempotent).
    if (err.requestOptions.method.toUpperCase() != 'GET') {
      return false;
    }

    // Never retry 4xx.
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return false;
    }

    // Retry on timeout errors.
    if (_isTimeout(err.type)) {
      return true;
    }

    // Retry on 5xx server errors.
    if (statusCode != null && statusCode >= 500) {
      return true;
    }

    // Retry on connection errors (transient).
    if (err.type == DioExceptionType.connectionError) {
      return true;
    }

    return false;
  }

  bool _isTimeout(DioExceptionType type) {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout;
  }

  Duration _computeDelay(int attempt) {
    final exponential = baseDelay * pow(2, attempt);
    final capped = exponential > maxDelay ? maxDelay : exponential;
    // Add small jitter (0–25% of delay) to avoid thundering herd.
    final jitter = Duration(
      milliseconds: (capped.inMilliseconds * 0.25 * Random().nextDouble()).toInt(),
    );
    return capped + jitter;
  }
}
