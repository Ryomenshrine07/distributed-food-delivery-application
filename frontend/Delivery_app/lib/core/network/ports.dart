import 'dart:async';

abstract class TokenStore {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

abstract class AuthEventSink {
  Stream<void> get onSessionExpired;
  void addSessionExpiredEvent();
}

abstract class LocationPausePort {
  void pauseHeartbeat();
}

// In-memory stubs for now
class InMemoryTokenStore implements TokenStore {
  String? _token;

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> saveToken(String token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;
}

class StubAuthEventSink implements AuthEventSink {
  final _controller = StreamController<void>.broadcast();

  @override
  Stream<void> get onSessionExpired => _controller.stream;

  @override
  void addSessionExpiredEvent() {
    _controller.add(null);
  }
}

class StubLocationPausePort implements LocationPausePort {
  @override
  void pauseHeartbeat() {
    // Stub
  }
}
