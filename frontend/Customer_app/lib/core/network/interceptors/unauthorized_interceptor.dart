import 'package:dio/dio.dart';

import '../auth_event_sink.dart';
import '../token_store.dart';

/// The single 401 seam for the entire app.
///
/// Uses [QueuedInterceptor] to serialize concurrent 401 handling, preventing
/// race conditions when multiple requests fail simultaneously.
///
/// Behaviour:
/// - On a **non-`/auth/**`** 401 response: clears the stored token via
///   [TokenStore] and emits `SessionExpired` via [AuthEventSink].
/// - On an `/auth/**` 401 (e.g. invalid login credentials): passes the error
///   through unmodified so it can be mapped to `InvalidCredentials` downstream.
class UnauthorizedInterceptor extends QueuedInterceptor {
  UnauthorizedInterceptor({
    required TokenStore tokenStore,
    required AuthEventSink authEventSink,
  })  : _tokenStore = tokenStore,
        _authEventSink = authEventSink;

  final TokenStore _tokenStore;
  final AuthEventSink _authEventSink;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    if (statusCode != 401) {
      handler.next(err);
      return;
    }

    // /auth/** 401s pass through (login/register failures).
    if (_isAuthPath(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    // Clear token and emit session expired for authenticated-route 401s.
    await _tokenStore.clear();
    _authEventSink.emitSessionExpired();

    handler.next(err);
  }

  bool _isAuthPath(String path) {
    final normalized = Uri.parse(path).path;
    return normalized.startsWith('/auth/') || normalized == '/auth';
  }
}
