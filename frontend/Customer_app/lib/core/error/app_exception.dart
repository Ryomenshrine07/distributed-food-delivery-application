/// Typed transport-layer exceptions thrown at the data boundary.
///
/// These are internal to the data layer and must never leak into presentation.
/// Repositories catch them and map to [Failure] via the error mapper.
sealed class AppException implements Exception {
  const AppException();
}

/// No internet connection detected before or during a request.
final class NoConnectionException extends AppException {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException';
}

/// Request exceeded the configured timeout (15 s connect/receive/send).
final class TimeoutException extends AppException {
  const TimeoutException();

  @override
  String toString() => 'TimeoutException';
}

/// HTTP 401 received on an authenticated (non-`/auth/**`) route.
final class UnauthorizedException extends AppException {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException';
}

/// HTTP 5xx server error.
final class ServerException extends AppException {
  const ServerException({required this.statusCode, this.message});

  final int statusCode;
  final String? message;

  @override
  String toString() => 'ServerException(statusCode: $statusCode, message: $message)';
}

/// HTTP 4xx client error (excluding 401, which becomes [UnauthorizedException]).
///
/// [fieldErrors] carries per-field validation messages from the server
/// (e.g. `{"email": ["already registered"]}`).
final class ClientException extends AppException {
  const ClientException({
    required this.statusCode,
    this.message,
    this.fieldErrors = const {},
  });

  final int statusCode;
  final String? message;
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() =>
      'ClientException(statusCode: $statusCode, message: $message, fieldErrors: $fieldErrors)';
}

/// The restaurant-service `ApiResponse` envelope returned `success == false`.
final class ApiEnvelopeException extends AppException {
  const ApiEnvelopeException({required this.message});

  final String message;

  @override
  String toString() => 'ApiEnvelopeException(message: $message)';
}

/// Catch-all for unexpected errors that don't fit other categories.
final class UnknownException extends AppException {
  const UnknownException({this.error, this.stackTrace});

  final Object? error;
  final StackTrace? stackTrace;

  @override
  String toString() => 'UnknownException(error: $error)';
}
