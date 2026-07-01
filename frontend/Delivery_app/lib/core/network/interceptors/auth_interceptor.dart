import 'package:dio/dio.dart';
import '../ports.dart';

class AuthInterceptor extends Interceptor {
  final TokenStore tokenStore;

  AuthInterceptor(this.tokenStore);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip attaching token for auth routes
    if (options.path.contains('/auth/')) {
      return handler.next(options);
    }

    final token = await tokenStore.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    return handler.next(options);
  }
}
