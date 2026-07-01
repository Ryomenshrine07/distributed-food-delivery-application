import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/core/network/interceptors/auth_interceptor.dart';
import 'package:delivery_app/core/network/ports.dart';

class MockTokenStore extends Mock implements TokenStore {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  group('AuthInterceptor Property-like Test', () {
    late AuthInterceptor interceptor;
    late MockTokenStore mockTokenStore;
    late MockRequestInterceptorHandler mockHandler;

    setUp(() {
      mockTokenStore = MockTokenStore();
      mockHandler = MockRequestInterceptorHandler();
      interceptor = AuthInterceptor(mockTokenStore);
      
      when(() => mockTokenStore.getToken()).thenAnswer((_) async => 'test-token');
    });

    test('Attaches token if path does not contain /auth/', () async {
      final paths = ['/api/delivery', '/deliveries/123', '/user/profile', '/some/other/path'];
      
      for (final path in paths) {
        final options = RequestOptions(path: path);
        interceptor.onRequest(options, mockHandler);
        
        // Wait for async execution
        await Future.delayed(const Duration(milliseconds: 10));
        
        verify(() => mockHandler.next(any(that: predicate<RequestOptions>((opts) {
          return opts.headers['Authorization'] == 'Bearer test-token';
        })))).called(1);
      }
    });

    test('Does NOT attach token if path contains /auth/', () async {
      final paths = ['/auth/login', '/api/auth/register', '/v1/auth/refresh'];
      
      for (final path in paths) {
        final options = RequestOptions(path: path);
        interceptor.onRequest(options, mockHandler);
        
        // Wait for async execution
        await Future.delayed(const Duration(milliseconds: 10));
        
        verify(() => mockHandler.next(any(that: predicate<RequestOptions>((opts) {
          return !opts.headers.containsKey('Authorization');
        })))).called(1);
      }
    });
  });
}
