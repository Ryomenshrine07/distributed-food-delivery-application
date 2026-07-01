import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/token_store.dart';

part 'secure_storage.g.dart';

/// Secure-storage-backed implementation of the network [TokenStore] port.
///
/// The JWT is the only value persisted here. It lives in the platform secure
/// store (Keychain on iOS/macOS, EncryptedSharedPreferences on Android) via
/// [FlutterSecureStorage], satisfying the requirement that the token is never
/// kept in plain storage (Req 25.1) and is cleared on logout / 401 (Req 25.4).
class SecureStorage implements TokenStore {
  /// Creates a [SecureStorage].
  ///
  /// A [FlutterSecureStorage] can be injected for testing; otherwise a
  /// hardened default (encrypted Android backing store) is used.
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? _defaultStorage();

  final FlutterSecureStorage _storage;

  /// Storage key under which the JWT is persisted.
  static const String jwtKey = 'jwt';

  static FlutterSecureStorage _defaultStorage() => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

  @override
  Future<String?> read() => _storage.read(key: jwtKey);

  @override
  Future<void> write(String token) =>
      _storage.write(key: jwtKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: jwtKey);
}

/// Composition-root binding for the network [TokenStore] port (task 4).
///
/// Defaults to throwing so the port MUST be bound at the composition root via
/// a provider override (see `main.dart`), where it is wired to [SecureStorage].
/// Tests override this provider with an in-memory fake.
@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => throw UnimplementedError(
      'tokenStoreProvider must be overridden at the composition root '
      'with a SecureStorage-backed binding.',
    );
