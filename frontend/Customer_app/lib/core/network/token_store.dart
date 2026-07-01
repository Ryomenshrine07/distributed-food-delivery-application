/// Composition-root port for reading and clearing the authentication token.
///
/// The permanent implementation is backed by `flutter_secure_storage` (task 5).
/// This in-memory binding is provided so the interceptor chain compiles and
/// is testable immediately.
abstract interface class TokenStore {
  /// Returns the current JWT token, or `null` if no session exists.
  Future<String?> read();

  /// Persists a new JWT token.
  Future<void> write(String token);

  /// Removes the stored token (logout / 401 clear).
  Future<void> clear();
}

/// Temporary in-memory implementation for early compilation and testing.
class InMemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
