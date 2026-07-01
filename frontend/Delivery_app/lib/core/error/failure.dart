sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NoConnectionFailure extends Failure {
  const NoConnectionFailure() : super('No internet connection');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure() : super('Request timed out');
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, dynamic> fieldErrors;
  const ValidationFailure(this.fieldErrors, [String message = 'Validation error']) : super(message);
}

class ConflictFailure extends Failure {
  const ConflictFailure([String message = 'Resource conflict']) : super(message);
}

class RateLimitFailure extends Failure {
  const RateLimitFailure([String message = 'Too many requests']) : super(message);
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure([String message = 'Invalid email or password']) : super(message);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure() : super('Session expired, please login again');
}

class LocationPermissionDeniedFailure extends Failure {
  const LocationPermissionDeniedFailure() : super('Location permission denied');
}

class GpsDisabledFailure extends Failure {
  const GpsDisabledFailure() : super('GPS is disabled');
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unknown error occurred']) : super(message);
}
