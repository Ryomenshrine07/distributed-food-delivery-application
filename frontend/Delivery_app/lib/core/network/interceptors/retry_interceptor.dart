import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../dio_provider.dart'; // We'll need access to the Dio instance or provide it via a getter. Actually, better pass Dio instance in constructor.

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final int initialDelayMillis;

  RetryInterceptor(this.dio, {this.maxRetries = 3, this.initialDelayMillis = 1000});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final method = err.requestOptions.method.toUpperCase();
    if (method != 'GET') {
      return handler.next(err);
    }

    final isTimeout = err.type == DioExceptionType.connectionTimeout || 
                      err.type == DioExceptionType.receiveTimeout || 
                      err.type == DioExceptionType.sendTimeout;
                      
    final isTransient5xx = err.response != null && err.response!.statusCode! >= 500;
    final isConnectionError = err.type == DioExceptionType.connectionError;

    if (isTimeout || isTransient5xx || isConnectionError) {
      int retryCount = err.requestOptions.extra['retryCount'] ?? 0;
      if (retryCount < maxRetries) {
        retryCount++;
        final delay = initialDelayMillis * pow(2, retryCount - 1);
        await Future.delayed(Duration(milliseconds: delay.toInt()));

        err.requestOptions.extra['retryCount'] = retryCount;

        try {
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          if (e is DioException) {
            return handler.next(e);
          }
          return handler.next(err);
        }
      }
    }

    return handler.next(err);
  }
}
