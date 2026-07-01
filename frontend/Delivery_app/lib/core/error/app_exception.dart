sealed class AppException implements Exception {
  const AppException();
}

class NoConnectionException extends AppException {
  const NoConnectionException();
}

class TimeoutException extends AppException {
  const TimeoutException();
}

class UnauthorizedException extends AppException {
  const UnauthorizedException();
}

class ServerException extends AppException {
  final int? statusCode;
  final String? message;
  const ServerException([this.statusCode, this.message]);
}

class ClientException extends AppException {
  final Map<String, dynamic> fieldErrors;
  final int? statusCode;
  final String? message;
  const ClientException(this.fieldErrors, [this.statusCode, this.message]);
}

class ApiEnvelopeException extends AppException {
  final String message;
  const ApiEnvelopeException(this.message);
}

class UnknownException extends AppException {
  final Object? error;
  const UnknownException([this.error]);
}
