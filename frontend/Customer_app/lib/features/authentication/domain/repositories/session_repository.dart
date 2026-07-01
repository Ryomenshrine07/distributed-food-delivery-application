import '../entities/identity_claims.dart';
import '../entities/session.dart';
import '../session_state.dart';

/// Interface for managing the user's authentication session.
///
/// Handles session persistence, retrieval, and lifecycle notifications.
/// The 401 seam (UnauthorizedInterceptor) and logout both call [clear].
abstract interface class SessionRepository {
  /// Returns the current session if a valid (non-expired) token exists.
  ///
  /// Returns `null` if no token is stored or the token has expired.
  /// An expired token is automatically cleared.
  Future<Session?> currentSession();

  /// Persists a new session (token) to secure storage.
  Future<void> persist(Session session);

  /// Clears the session (logout / 401 expiry).
  ///
  /// Removes the token from secure storage and emits [SessionState.unauthenticated]
  /// or [SessionState.expired] on the [changes] stream.
  Future<void> clear({bool isExpiry = false});

  /// A stream of session lifecycle state changes.
  ///
  /// Drives the router's `refreshListenable` for automatic redirect on
  /// login, logout, and session expiry.
  Stream<SessionState> changes();

  /// Returns the decoded identity claims from the current JWT, or `null`
  /// if no session exists.
  IdentityClaims? claims();
}
