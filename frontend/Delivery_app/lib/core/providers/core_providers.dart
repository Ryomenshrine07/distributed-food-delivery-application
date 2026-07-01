import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/storage/secure_token_store.dart';
import '../../core/network/ports.dart';
import '../../core/storage/secure_storage_wrapper.dart';
import '../../core/network/dio_provider.dart';
import '../../core/network/api_client.dart';

final secureStorageProvider = Provider<SecureStorageWrapper>((ref) {
  return SecureStorageWrapper(storage: const FlutterSecureStorage());
});

final tokenStoreProvider = Provider<TokenStore>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecureTokenStore(storage);
});

final authEventSinkProvider = Provider<AuthEventSink>((ref) {
  return StubAuthEventSink();
});

final dioProvider = Provider((ref) {
  return createDio(
    tokenStore: ref.watch(tokenStoreProvider),
    authEventSink: ref.watch(authEventSinkProvider),
    locationPausePort: StubLocationPausePort(),
  );
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

class StubLocationPausePort implements LocationPausePort {
  @override
  void pauseHeartbeat() {}
}
