import 'dart:io' show SocketException;

import 'package:dio/dio.dart';

import '../../error/app_exception.dart';

/// Converts any [DioException] into a typed [AppException].
///
/// This is the last interceptor in the chain and guarantees that all errors
/// leaving the networking layer are expressed as domain exceptions, never
/// raw Dio types.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _mapToAppException(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appException,
        stackTrace: err.stackTrace,
      ),
    );
  }

  AppException _mapToAppException(DioException err) {
    // Connection errors (no internet).
    if (err.type == DioExceptionType.connectionError ||
        err.error is SocketException) {
      return const NoConnectionException();
    }

    // Timeout errors.
    if (_isTimeout(err.type)) {
      return const TimeoutException();
    }

    // HTTP response errors.
    final statusCode = err.response?.statusCode;
    if (statusCode != null) {
      return _mapStatusCode(statusCode, err);
    }

    // Cancel is not an error we throw — it's expected flow control.
    if (err.type == DioExceptionType.cancel) {
      return UnknownException(error: err, stackTrace: err.stackTrace);
    }

    // Fallback.
    return UnknownException(error: err.error, stackTrace: err.stackTrace);
  }

  AppException _mapStatusCode(int statusCode, DioException err) {
    if (statusCode == 401) {
      return const UnauthorizedException();
    }

    if (statusCode >= 500) {
      return ServerException(
        statusCode: statusCode,
        message: _extractMessage(err.response?.data),
      );
    }

    if (statusCode >= 400) {
      return ClientException(
        statusCode: statusCode,
        message: _extractMessage(err.response?.data),
        fieldErrors: _extractFieldErrors(err.response?.data),
      );
    }

    return UnknownException(error: err.error, stackTrace: err.stackTrace);
  }

  bool _isTimeout(DioExceptionType type) {
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.receiveTimeout ||
        type == DioExceptionType.sendTimeout;
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }

  Map<String, List<String>> _extractFieldErrors(dynamic data) {
    if (data is! Map<String, dynamic>) return const {};

    final errors = data['errors'] ?? data['fieldErrors'];
    if (errors is Map<String, dynamic>) {
      return errors.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.cast<String>());
        }
        return MapEntry(key, <String>[value.toString()]);
      });
    }
    return const {};
  }
}
