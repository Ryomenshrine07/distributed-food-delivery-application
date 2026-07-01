/// Session states emitted by [SessionRepository.changes].
enum SessionState {
  /// User has an active, valid session.
  authenticated,

  /// No session or session has expired / been cleared.
  unauthenticated,

  /// Server rejected the token (401 on an authenticated route).
  expired,
}
