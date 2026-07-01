/// UI-facing failure types returned by repositories inside [Result].
///
/// Each subclass represents a distinct user-visible error condition.
/// Presentation layers pattern-match on these to render appropriate messages.
sealed class Failure {
  const Failure({this.message = ''});

  /// A human-readable message suitable for display or logging.
  final String message;
}

/// No internet connection available.
final class NoConnectionFailure extends Failure {
  const NoConnectionFailure({super.message = 'No internet connection'});

  @override
  String toString() => 'NoConnectionFailure(message: $message)';
}

/// Request timed out.
final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timed out'});

  @override
  String toString() => 'TimeoutFailure(message: $message)';
}

/// Server returned an HTTP 5xx or the API envelope indicated failure.
final class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error'});

  @override
  String toString() => 'ServerFailure(message: $message)';
}

/// HTTP 400 with per-field validation errors.
///
/// [fieldErrors] maps field names to their validation messages,
/// e.g. `{"email": ["already registered"], "phone": ["invalid format"]}`.
final class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation failed',
    this.fieldErrors = const {},
  });

  final Map<String, List<String>> fieldErrors;

  @override
  String toString() =>
      'ValidationFailure(message: $message, fieldErrors: $fieldErrors)';
}

/// HTTP 409 — resource conflict (e.g. duplicate account).
final class ConflictFailure extends Failure {
  const ConflictFailure({super.message = 'Conflict'});

  @override
  String toString() => 'ConflictFailure(message: $message)';
}

/// HTTP 429 — rate limit exceeded.
final class RateLimitFailure extends Failure {
  const RateLimitFailure({super.message = 'Rate limit exceeded'});

  @override
  String toString() => 'RateLimitFailure(message: $message)';
}

/// HTTP 401 on an `/auth/**` endpoint — email or password is incorrect.
final class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure(
      {super.message = 'Invalid email or password'});

  @override
  String toString() => 'InvalidCredentialsFailure(message: $message)';
}

/// HTTP 401 on a non-`/auth/**` route — session expired or token invalid.
final class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure({super.message = 'Session expired'});

  @override
  String toString() => 'SessionExpiredFailure(message: $message)';
}

/// Catch-all for unmapped or unexpected errors.
final class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'});

  @override
  String toString() => 'UnknownFailure(message: $message)';
}
