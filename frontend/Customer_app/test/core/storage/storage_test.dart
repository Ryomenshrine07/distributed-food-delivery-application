// Unit tests for the core storage wrappers.
//
// Covers:
// - [SecureStorage] (the secure-storage-backed [TokenStore]): JWT
//   read / write / clear, using the flutter_secure_storage in-memory fake.
// - [Preferences] (SharedPreferences wrapper): theme-mode read / write /
//   default, using the SharedPreferences in-memory fake.
// - Composition-root bindings: tokenStoreProvider / sharedPreferencesProvider /
//   preferencesProvider resolve through provider overrides and demand an
//   override when unbound.
//
// **Validates: Requirements 25.1, 25.4**

import 'package:customer_app/core/network/token_store.dart';
import 'package:customer_app/core/storage/preferences.dart';
import 'package:customer_app/core/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorage (TokenStore)', () {
    setUp(() {
      // Reset to a fresh in-memory secure-storage backend for each test.
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('is a TokenStore', () {
      expect(SecureStorage(), isA<TokenStore>());
    });

    test('read returns null when no token is stored', () async {
      final store = SecureStorage();
      expect(await store.read(), isNull);
    });

    test('write then read returns the stored token', () async {
      final store = SecureStorage();
      await store.write('jwt-abc-123');
      expect(await store.read(), equals('jwt-abc-123'));
    });

    test('write overwrites a previously stored token', () async {
      final store = SecureStorage();
      await store.write('first-token');
      await store.write('second-token');
      expect(await store.read(), equals('second-token'));
    });

    test('clear removes the stored token', () async {
      final store = SecureStorage();
      await store.write('to-be-cleared');
      await store.clear();
      expect(await store.read(), isNull);
    });

    test('clear is a no-op when nothing is stored', () async {
      final store = SecureStorage();
      await store.clear();
      expect(await store.read(), isNull);
    });

    test('reads a token that pre-exists in secure storage', () async {
      FlutterSecureStorage.setMockInitialValues({
        SecureStorage.jwtKey: 'pre-existing-token',
      });
      final store = SecureStorage();
      expect(await store.read(), equals('pre-existing-token'));
    });
  });

  group('Preferences (theme mode)', () {
    Future<Preferences> buildPreferences() async {
      final prefs = await SharedPreferences.getInstance();
      return Preferences(prefs);
    }

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('readThemeMode defaults to system when no preference is stored',
        () async {
      final preferences = await buildPreferences();
      expect(preferences.readThemeMode(), ThemeMode.system);
    });

    test('writeThemeMode then readThemeMode round-trips light', () async {
      final preferences = await buildPreferences();
      await preferences.writeThemeMode(ThemeMode.light);
      expect(preferences.readThemeMode(), ThemeMode.light);
    });

    test('writeThemeMode then readThemeMode round-trips dark', () async {
      final preferences = await buildPreferences();
      await preferences.writeThemeMode(ThemeMode.dark);
      expect(preferences.readThemeMode(), ThemeMode.dark);
    });

    test('writeThemeMode then readThemeMode round-trips system', () async {
      final preferences = await buildPreferences();
      await preferences.writeThemeMode(ThemeMode.dark);
      await preferences.writeThemeMode(ThemeMode.system);
      expect(preferences.readThemeMode(), ThemeMode.system);
    });

    test('readThemeMode falls back to system for an unrecognized value',
        () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Preferences.themeModeKey, 'neon');
      final preferences = Preferences(prefs);
      expect(preferences.readThemeMode(), ThemeMode.system);
    });
  });

  group('Composition-root provider bindings', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
    });

    test('tokenStoreProvider resolves to the overridden SecureStorage', () {
      final secureStorage = SecureStorage();
      final container = ProviderContainer(
        overrides: [tokenStoreProvider.overrideWithValue(secureStorage)],
      );
      addTearDown(container.dispose);

      expect(container.read(tokenStoreProvider), same(secureStorage));
    });

    test('tokenStoreProvider throws until bound at the composition root', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(tokenStoreProvider),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('preferencesProvider builds Preferences from the bound SharedPreferences',
        () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final preferences = container.read(preferencesProvider);
      await preferences.writeThemeMode(ThemeMode.dark);
      expect(preferences.readThemeMode(), ThemeMode.dark);
    });

    test('sharedPreferencesProvider throws until bound at the composition root',
        () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(sharedPreferencesProvider),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
