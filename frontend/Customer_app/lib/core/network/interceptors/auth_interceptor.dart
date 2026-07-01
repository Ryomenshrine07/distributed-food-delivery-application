import 'package:dio/dio.dart';

import '../token_store.dart';

/// Attaches `Authorization: Bearer <token>` to every request whose path
/// is NOT under `/auth/`.
///
/// In non-local builds (determined by [isLocal]), forces HTTPS by rewriting
/// the request URI scheme to `https`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStore tokenStore,
    this.isLocal = true,
  }) : _tokenStore = tokenStore;

  final TokenStore _tokenStore;

  /// When `false`, the interceptor rewrites HTTP → HTTPS.
  final bool isLocal;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Force HTTPS in non-local environments.
    if (!isLocal && options.uri.scheme == 'http') {
      options.path = options.uri.replace(scheme: 'https').toString();
    }

    // Skip auth header for authentication endpoints.
    if (_isAuthPath(options.path)) {
      handler.next(options);
      return;
    }

    final token = await _tokenStore.read();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  /// Returns `true` when the path is under `/auth/`.
  bool _isAuthPath(String path) {
    final normalized = Uri.parse(path).path;
    return normalized.startsWith('/auth/') || normalized == '/auth';
  }
}
