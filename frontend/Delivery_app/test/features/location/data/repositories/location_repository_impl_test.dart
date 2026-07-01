import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:delivery_app/core/network/api_client.dart';
import 'package:delivery_app/features/authentication/domain/repositories/session_repository.dart';
import 'package:delivery_app/features/authentication/domain/entities/partner_session.dart';
import 'package:delivery_app/features/location/data/repositories/location_repository_impl.dart';
import 'package:delivery_app/core/error/failure.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockSessionRepository extends Mock implements SessionRepository {}
class FakePartnerSession extends Fake implements PartnerSession {
  @override
  final String partnerId = 'partner-123';
  @override
  bool get isExpired => false;
}

void main() {
  group('LocationRepositoryImpl', () {
    late MockApiClient mockApiClient;
    late MockSessionRepository mockSessionRepository;
    late LocationRepositoryImpl repository;

    setUp(() {
      mockApiClient = MockApiClient();
      mockSessionRepository = MockSessionRepository();
      repository = LocationRepositoryImpl(mockApiClient, mockSessionRepository);
    });

    test('submitHeartbeat successfully submits valid coordinates', () async {
      final fakeSession = FakePartnerSession();
      when(() => mockSessionRepository.currentSession).thenReturn(fakeSession);
      when(() => mockApiClient.postVoid(any(), data: any(named: 'data')))
          .thenAnswer((_) async {});

      final result = await repository.submitHeartbeat(12.9716, 77.5946);

      result.fold(
        (l) => fail('Should return Right'),
        (r) {},
      );

      verify(() => mockApiClient.postVoid(
        '/api/delivery/partners/partner-123/location',
        data: {'latitude': 12.9716, 'longitude': 77.5946},
      )).called(1);
    });

    test('submitHeartbeat returns ValidationFailure for invalid coordinates', () async {
      final fakeSession = FakePartnerSession();
      when(() => mockSessionRepository.currentSession).thenReturn(fakeSession);

      final result = await repository.submitHeartbeat(100.0, 200.0);

      result.fold(
        (l) {
          expect(l, isA<ValidationFailure>());
        },
        (r) => fail('Should return Left'),
      );

      verifyNever(() => mockApiClient.postVoid(any(), data: any(named: 'data')));
    });

    test('submitHeartbeat returns SessionExpiredFailure when session is missing', () async {
      when(() => mockSessionRepository.currentSession).thenReturn(null);

      final result = await repository.submitHeartbeat(12.9716, 77.5946);

      result.fold(
        (l) => expect(l, isA<SessionExpiredFailure>()),
        (r) => fail('Should return Left'),
      );

      verifyNever(() => mockApiClient.postVoid(any(), data: any(named: 'data')));
    });
  });
}
