/// Composition-root port for emitting authentication lifecycle events.
///
/// The permanent implementation is bound by the session layer (task 8).
/// This no-op binding is provided so the interceptor chain compiles and
/// is testable immediately.
abstract interface class AuthEventSink {
  /// Notifies the session layer that the server rejected the current token.
  void emitSessionExpired();
}

/// Temporary no-op implementation for early compilation and testing.
class NoOpAuthEventSink implements AuthEventSink {
  @override
  void emitSessionExpired() {
    // Will be replaced by a real implementation in task 8.
  }
}
