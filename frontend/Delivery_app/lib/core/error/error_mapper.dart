import 'package:dio/dio.dart';
import 'app_exception.dart';
import 'failure.dart';

class ErrorMapper {
  static Failure mapToFailure(dynamic exception) {
    if (exception is DioException) {
      if (exception.error is AppException) {
        return _mapAppException(exception.error as AppException);
      }
      return const UnknownFailure('Network error occurred');
    }
    
    if (exception is AppException) {
      return _mapAppException(exception);
    }
    
    return UnknownFailure(exception.toString());
  }

  static Failure _mapAppException(AppException exception) {
    if (exception is NoConnectionException) {
      return const NoConnectionFailure();
    } else if (exception is TimeoutException) {
      return const TimeoutFailure();
    } else if (exception is UnauthorizedException) {
      return const SessionExpiredFailure(); // Or InvalidCredentials depending on context, handled higher up or generic here
    } else if (exception is ServerException) {
      return ServerFailure(exception.message ?? 'Server error occurred');
    } else if (exception is ClientException) {
      if (exception.statusCode == 401) {
        return const InvalidCredentialsFailure();
      } else if (exception.statusCode == 409) {
        return const ConflictFailure();
      } else if (exception.statusCode == 429) {
        return const RateLimitFailure();
      } else if (exception.statusCode == 400) {
        return ValidationFailure(exception.fieldErrors, exception.message ?? 'Validation error');
      }
      return UnknownFailure(exception.message ?? 'Client error');
    } else if (exception is ApiEnvelopeException) {
      return UnknownFailure(exception.message);
    } else if (exception is UnknownException) {
      return UnknownFailure(exception.error?.toString() ?? 'Unknown error');
    }
    return const UnknownFailure();
  }
}
