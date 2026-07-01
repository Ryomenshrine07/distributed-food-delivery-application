import 'app_exception.dart';
import 'failure.dart';

/// Maps a transport-layer [AppException] to a UI-facing [Failure].
///
/// This is a pure function with exhaustive pattern matching on the sealed
/// [AppException] hierarchy. Every transport outcome maps to exactly one
/// [Failure] subtype. Server field-error maps are preserved for HTTP 400.
Failure mapExceptionToFailure(AppException exception) {
  return switch (exception) {
    NoConnectionException() => const NoConnectionFailure(),
    TimeoutException() => const TimeoutFailure(),
    UnauthorizedException() => const SessionExpiredFailure(),
    ServerException(:final message) =>
      ServerFailure(message: message ?? 'Server error'),
    ClientException(:final statusCode, :final message, :final fieldErrors) =>
      _mapClientException(statusCode, message, fieldErrors),
    ApiEnvelopeException(:final message) => ServerFailure(message: message),
    UnknownException(:final error) =>
      UnknownFailure(message: error?.toString() ?? 'An unexpected error occurred'),
  };
}

/// Maps a [ClientException] to the appropriate [Failure] based on status code.
Failure _mapClientException(
  int statusCode,
  String? message,
  Map<String, List<String>> fieldErrors,
) {
  return switch (statusCode) {
    400 => ValidationFailure(
        message: message ?? 'Validation failed',
        fieldErrors: fieldErrors,
      ),
    401 => const InvalidCredentialsFailure(),
    409 => ConflictFailure(message: message ?? 'Conflict'),
    429 => const RateLimitFailure(),
    _ => UnknownFailure(message: message ?? 'An unexpected error occurred'),
  };
}
