import 'package:dio/dio.dart';
import '../../error/app_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        appException = const TimeoutException();
        break;
      case DioExceptionType.connectionError:
        appException = const NoConnectionException();
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final data = err.response?.data;
        if (statusCode == 401) {
          appException = const UnauthorizedException();
        } else if (statusCode != null && statusCode >= 500) {
          appException = ServerException(statusCode, _extractMessage(data));
        } else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          if (data is Map<String, dynamic> && data.containsKey('errors')) {
            appException = ClientException(
              Map<String, dynamic>.from(data['errors']),
              statusCode,
              _extractMessage(data),
            );
          } else {
            appException = ClientException(
              const {},
              statusCode,
              _extractMessage(data),
            );
          }
        } else {
          appException = UnknownException(err);
        }
        break;
      case DioExceptionType.cancel:
        appException = const UnknownException('Request cancelled');
        break;
      default:
        appException = UnknownException(err.error ?? err.message);
    }

    // Pass the mapped AppException wrapped inside the DioException
    final modifiedError = err.copyWith(error: appException);
    return handler.next(modifiedError);
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('error')) return data['error'].toString();
    }
    return null;
  }
}
