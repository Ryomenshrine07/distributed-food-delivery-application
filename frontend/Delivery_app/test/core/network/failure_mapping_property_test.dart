import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:delivery_app/core/error/app_exception.dart';
import 'package:delivery_app/core/error/failure.dart';
import 'package:delivery_app/core/error/error_mapper.dart';
import 'package:delivery_app/core/network/interceptors/error_interceptor.dart';
import 'package:mocktail/mocktail.dart';

class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}
class FakeDioException extends Fake implements DioException {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDioException());
  });

  group('Failure Mapping Property-like Test', () {
    late ErrorInterceptor interceptor;
    late MockErrorInterceptorHandler mockHandler;

    setUp(() {
      interceptor = ErrorInterceptor();
      mockHandler = MockErrorInterceptorHandler();
    });

    DioException getModifiedError(DioException original) {
      DioException? modified;
      when(() => mockHandler.next(any())).thenAnswer((inv) {
        modified = inv.positionalArguments[0] as DioException;
      });
      interceptor.onError(original, mockHandler);
      return modified!;
    }

    test('Maps timeout exceptions to TimeoutFailure', () {
      final types = [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      ];
      
      for (final type in types) {
        final original = DioException(requestOptions: RequestOptions(path: ''), type: type);
        final modified = getModifiedError(original);
        expect(modified.error, isA<TimeoutException>());
        
        final failure = ErrorMapper.mapToFailure(modified);
        expect(failure, isA<TimeoutFailure>());
      }
    });

    test('Maps connection error to NoConnectionFailure', () {
      final original = DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.connectionError);
      final modified = getModifiedError(original);
      
      expect(modified.error, isA<NoConnectionException>());
      
      final failure = ErrorMapper.mapToFailure(modified);
      expect(failure, isA<NoConnectionFailure>());
    });

    test('Maps 401 to SessionExpiredFailure or InvalidCredentialsFailure', () {
      final response = Response(requestOptions: RequestOptions(path: ''), statusCode: 401);
      final original = DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.badResponse, response: response);
      final modified = getModifiedError(original);
      
      expect(modified.error, isA<UnauthorizedException>());
      
      final failure = ErrorMapper.mapToFailure(modified);
      expect(failure, isA<SessionExpiredFailure>());
    });

    test('Maps 5xx to ServerFailure', () {
      final response = Response(requestOptions: RequestOptions(path: ''), statusCode: 503, data: {'message': 'Service Unavailable'});
      final original = DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.badResponse, response: response);
      final modified = getModifiedError(original);
      
      expect(modified.error, isA<ServerException>());
      
      final failure = ErrorMapper.mapToFailure(modified);
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).message, 'Service Unavailable');
    });

    test('Maps 400 with errors to ValidationFailure', () {
      final fieldErrors = {'email': 'Invalid email'};
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 400,
        data: {'errors': fieldErrors, 'message': 'Validation failed'},
      );
      final original = DioException(requestOptions: RequestOptions(path: ''), type: DioExceptionType.badResponse, response: response);
      final modified = getModifiedError(original);
      
      expect(modified.error, isA<ClientException>());
      
      final failure = ErrorMapper.mapToFailure(modified);
      expect(failure, isA<ValidationFailure>());
      expect((failure as ValidationFailure).fieldErrors, fieldErrors);
      expect(failure.message, 'Validation failed');
    });
  });
}
