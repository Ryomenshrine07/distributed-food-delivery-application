import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Signature for a log sink function used by [LoggingInterceptor].
///
/// Defaults to [developer.log]; injectable for testing.
typedef LogSink = void Function(String message, {String name});

/// Logs HTTP requests and responses while redacting sensitive values.
///
/// Redacted:
/// - `Authorization` header value
/// - Any field named `password`, `token`, or `refreshToken` in request/response bodies
class LoggingInterceptor extends Interceptor {
  /// Creates a [LoggingInterceptor].
  ///
  /// An optional [logSink] can be provided for testing. When omitted,
  /// logs are written via [developer.log].
  LoggingInterceptor({LogSink? logSink})
      : _log = logSink ?? ((message, {name = 'HTTP'}) => developer.log(message, name: name));

  final LogSink _log;

  @visibleForTesting
  static const redacted = '***REDACTED***';

  static const _sensitiveHeaders = {'authorization'};

  static const _sensitiveBodyFields = {
    'password',
    'token',
    'refreshtoken',
    'refresh_token',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final headers = _redactHeaders(options.headers);
    final body = _redactBody(options.data);

    _log(
      '→ ${options.method} ${options.uri}\n'
      '  Headers: $headers\n'
      '  Body: $body',
      name: 'HTTP',
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = _redactBody(response.data);

    _log(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}\n'
      '  Body: $body',
      name: 'HTTP',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log(
      '✗ ${err.requestOptions.method} ${err.requestOptions.uri}\n'
      '  Status: ${err.response?.statusCode}\n'
      '  Message: ${err.message}',
      name: 'HTTP',
    );

    handler.next(err);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    return headers.map((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        return MapEntry(key, redacted);
      }
      return MapEntry(key, value);
    });
  }

  Object? _redactBody(Object? data) {
    if (data is Map<String, dynamic>) {
      return data.map((key, value) {
        if (_sensitiveBodyFields.contains(key.toLowerCase())) {
          return MapEntry(key, redacted);
        }
        if (value is Map<String, dynamic>) {
          return MapEntry(key, _redactBody(value));
        }
        return MapEntry(key, value);
      });
    }
    return data;
  }
}
