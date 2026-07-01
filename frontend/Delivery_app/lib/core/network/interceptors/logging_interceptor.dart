import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> ${options.method.toUpperCase()} ${options.uri}');
      debugPrint('Headers: ${_redactHeaders(options.headers)}');
      if (options.data != null) {
        debugPrint('Body: ${_redactBody(options.data)}');
      }
      debugPrint('--> END ${options.method.toUpperCase()}');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
      if (response.data != null) {
        debugPrint('Body: ${_redactBody(response.data)}');
      }
      debugPrint('<-- END HTTP');
    }
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- Error ${err.message} ${err.requestOptions.uri}');
      if (err.response?.data != null) {
        debugPrint('Error Body: ${_redactBody(err.response?.data)}');
      }
      debugPrint('<-- END HTTP');
    }
    return handler.next(err);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final redacted = Map<String, dynamic>.from(headers);
    if (redacted.containsKey('Authorization')) {
      redacted['Authorization'] = '***REDACTED***';
    }
    return redacted;
  }

  dynamic _redactBody(dynamic data) {
    if (data is Map<String, dynamic>) {
      final redacted = Map<String, dynamic>.from(data);
      final keysToRedact = ['password', 'token', 'latitude', 'longitude'];
      
      for (final key in redacted.keys.toList()) {
        if (keysToRedact.contains(key.toLowerCase())) {
          redacted[key] = '***REDACTED***';
        } else if (redacted[key] is Map<String, dynamic> || redacted[key] is List) {
          redacted[key] = _redactBody(redacted[key]);
        }
      }
      return redacted;
    } else if (data is List) {
      return data.map((e) => _redactBody(e)).toList();
    }
    return data;
  }
}
