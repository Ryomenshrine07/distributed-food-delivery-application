import '../network/ports.dart';
import 'secure_storage_wrapper.dart';

class SecureTokenStore implements TokenStore {
  static const _tokenKey = 'auth_token';
  final SecureStorageWrapper _storage;

  SecureTokenStore(this._storage);

  @override
  Future<String?> getToken() async {
    return await _storage.read(_tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  @override
  Future<void> clearToken() async {
    await _storage.delete(_tokenKey);
  }
}
