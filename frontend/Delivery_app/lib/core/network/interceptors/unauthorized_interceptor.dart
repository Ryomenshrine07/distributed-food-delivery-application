import 'package:dio/dio.dart';
import '../ports.dart';

class UnauthorizedInterceptor extends QueuedInterceptor {
  final TokenStore tokenStore;
  final AuthEventSink authEventSink;
  final LocationPausePort locationPausePort;

  UnauthorizedInterceptor(this.tokenStore, this.authEventSink, this.locationPausePort);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (!err.requestOptions.path.contains('/auth/')) {
        await tokenStore.clearToken();
        locationPausePort.pauseHeartbeat();
        authEventSink.addSessionExpiredEvent();
      }
    }
    return handler.next(err);
  }
}
