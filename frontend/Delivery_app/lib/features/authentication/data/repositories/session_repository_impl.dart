import 'dart:async';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../core/storage/secure_token_store.dart';
import '../../../../core/network/ports.dart';
import '../../domain/entities/partner_session.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final TokenStore _tokenStore;
  final AuthEventSink _authEventSink;
  final StreamController<PartnerSession?> _sessionController = StreamController<PartnerSession?>.broadcast();
  PartnerSession? _currentSession;

  SessionRepositoryImpl(this._tokenStore, this._authEventSink) {
    _init();
  }

  Future<void> _init() async {
    final token = await _tokenStore.getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      _currentSession = _decodeToken(token);
    } else if (token != null) {
      await _tokenStore.clearToken();
    }
    _sessionController.add(_currentSession);
    
    // Listen to unauthorized events to clear session
    _authEventSink.onSessionExpired.listen((_) {
      clearSession();
    });
  }

  @override
  Stream<PartnerSession?> get sessionChanges => _sessionController.stream;

  @override
  PartnerSession? get currentSession => _currentSession;

  @override
  Future<void> saveSession(String token) async {
    await _tokenStore.saveToken(token);
    _currentSession = _decodeToken(token);
    _sessionController.add(_currentSession);
  }

  @override
  Future<void> clearSession() async {
    await _tokenStore.clearToken();
    _currentSession = null;
    _sessionController.add(null);
  }

  PartnerSession _decodeToken(String token) {
    final Map<String, dynamic> decoded = JwtDecoder.decode(token);
    
    return PartnerSession(
      partnerId: decoded['id'] ?? decoded['sub'] ?? '',
      email: decoded['email'] ?? '',
      role: decoded['role'] ?? '',
      name: decoded['name'] ?? decoded['fullName'] ?? '',
      phone: decoded['phone'] ?? '',
      exp: JwtDecoder.getExpirationDate(token),
    );
  }
}
