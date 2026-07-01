import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/network/auth_event_sink.dart';
import '../../core/network/dio_provider.dart';
import '../../core/network/token_store.dart';
import '../../core/storage/secure_storage.dart';
import '../authentication/data/mappers/auth_mapper.dart';
import '../authentication/domain/entities/identity_claims.dart';
import '../authentication/domain/entities/session.dart';
import '../authentication/domain/repositories/session_repository.dart';
import '../authentication/domain/session_state.dart';

part 'session_repository_impl.g.dart';

/// Secure-storage-backed implementation of [SessionRepository].
///
/// Reads/writes the JWT via [TokenStore] and decodes claims via [AuthMapper].
/// Implements [AuthEventSink] so the 401 seam can trigger session expiry.
class SessionRepositoryImpl implements SessionRepository, AuthEventSink {
  SessionRepositoryImpl({required TokenStore tokenStore})
      : _tokenStore = tokenStore;

  final TokenStore _tokenStore;
  final _controller = StreamController<SessionState>.broadcast();
  IdentityClaims? _cachedClaims;

  @override
  Future<Session?> currentSession() async {
    final token = await _tokenStore.read();
    if (token == null) return null;

    final claims = AuthMapper.claimsFromToken(token);
    if (claims == null || claims.isExpired) {
      await clear();
      return null;
    }

    _cachedClaims = claims;
    return Session(token: token, claims: claims);
  }

  @override
  Future<void> persist(Session session) async {
    await _tokenStore.write(session.token);
    _cachedClaims = session.claims;
    _controller.add(SessionState.authenticated);
  }

  @override
  Future<void> clear({bool isExpiry = false}) async {
    await _tokenStore.clear();
    _cachedClaims = null;
    _controller.add(
      isExpiry ? SessionState.expired : SessionState.unauthenticated,
    );
  }

  @override
  Stream<SessionState> changes() => _controller.stream;

  @override
  IdentityClaims? claims() => _cachedClaims;

  /// [AuthEventSink] implementation — called by the 401 seam.
  @override
  void emitSessionExpired() {
    clear(isExpiry: true);
  }

  /// Clean up resources.
  void dispose() {
    _controller.close();
  }
}

/// Provides the [SessionRepositoryImpl] singleton, bound at the composition root.
///
/// Also serves as the [AuthEventSink] for the unauthorized interceptor.
@Riverpod(keepAlive: true)
SessionRepositoryImpl sessionRepository(Ref ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final repo = SessionRepositoryImpl(tokenStore: tokenStore);

  // Initialize the DioProvider singleton with our actual implementations
  // so that ApiClient() instantiations grab the correct interceptors.
  DioProvider.reset();
  DioProvider.instance(
    tokenStore: tokenStore,
    authEventSink: repo,
  );

  ref.onDispose(repo.dispose);
  return repo;
}
