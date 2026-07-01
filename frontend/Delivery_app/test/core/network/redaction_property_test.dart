import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:delivery_app/core/network/interceptors/logging_interceptor.dart';
import 'package:mocktail/mocktail.dart';

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });

  group('LoggingInterceptor Redaction Test', () {
    late LoggingInterceptor interceptor;
    late MockRequestInterceptorHandler mockHandler;

    setUp(() {
      interceptor = LoggingInterceptor();
      mockHandler = MockRequestInterceptorHandler();
      when(() => mockHandler.next(any())).thenReturn(null);
    });

    test('Redacts sensitive keys in request headers and body', () async {
      final options = RequestOptions(
        path: '/api/test',
        method: 'POST',
        headers: {
          'Authorization': 'Bearer super-secret-token',
          'Content-Type': 'application/json',
        },
        data: {
          'email': 'test@test.com',
          'password': 'my-secret-password',
          'token': 'another-secret',
          'location': {
            'latitude': 12.34,
            'longitude': 56.78,
          }
        },
      );

      final logMessages = <String>[];
      
      // Override debugPrint temporarily to capture logs
      final originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) logMessages.add(message);
      };

      try {
        interceptor.onRequest(options, mockHandler);
      } finally {
        debugPrint = originalDebugPrint;
      }

      final logsJoined = logMessages.join('\n');
      
      expect(logsJoined, isNot(contains('super-secret-token')));
      expect(logsJoined, isNot(contains('my-secret-password')));
      expect(logsJoined, isNot(contains('another-secret')));
      expect(logsJoined, isNot(contains('12.34')));
      expect(logsJoined, isNot(contains('56.78')));
      
      expect(logsJoined, contains('***REDACTED***'));
      expect(logsJoined, contains('test@test.com')); // Non-sensitive data should be kept
    });
  });
}
