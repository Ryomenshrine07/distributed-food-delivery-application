import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/core/storage/secure_storage_wrapper.dart';
import 'package:delivery_app/core/storage/secure_token_store.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('SecureTokenStore', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureStorageWrapper wrapper;
    late SecureTokenStore tokenStore;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      wrapper = SecureStorageWrapper(storage: mockStorage);
      tokenStore = SecureTokenStore(wrapper);
    });

    test('getToken reads from storage', () async {
      when(() => mockStorage.read(key: 'auth_token')).thenAnswer((_) async => 'my-token');
      
      final token = await tokenStore.getToken();
      
      expect(token, 'my-token');
      verify(() => mockStorage.read(key: 'auth_token')).called(1);
    });

    test('saveToken writes to storage', () async {
      when(() => mockStorage.write(key: 'auth_token', value: 'new-token')).thenAnswer((_) async {});
      
      await tokenStore.saveToken('new-token');
      
      verify(() => mockStorage.write(key: 'auth_token', value: 'new-token')).called(1);
    });

    test('clearToken deletes from storage', () async {
      when(() => mockStorage.delete(key: 'auth_token')).thenAnswer((_) async {});
      
      await tokenStore.clearToken();
      
      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
    });
  });
}
