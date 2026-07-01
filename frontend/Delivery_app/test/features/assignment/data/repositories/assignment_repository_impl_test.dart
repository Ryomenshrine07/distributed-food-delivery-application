import 'package:delivery_app/core/error/failure.dart';
import 'package:delivery_app/core/error/result.dart';
import 'package:delivery_app/core/network/api_client.dart';
import 'package:delivery_app/core/offline_queue/offline_queue.dart';
import 'package:delivery_app/core/offline_queue/pending_confirmation.dart';
import 'package:delivery_app/features/assignment/data/repositories/assignment_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockOfflineQueue extends Mock implements OfflineQueue {}

void main() {
  late MockApiClient mockApiClient;
  late MockSharedPreferences mockPrefs;
  late MockOfflineQueue mockQueue;
  late AssignmentRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockPrefs = MockSharedPreferences();
    mockQueue = MockOfflineQueue();

    registerFallbackValue(
      PendingConfirmation(
        id: '123',
        orderId: 'order_123',
        type: ConfirmationType.pickedUp,
        enqueuedAt: DateTime.now(),
      )
    );

    repository = AssignmentRepositoryImpl(
      apiClient: mockApiClient,
      prefs: mockPrefs,
      offlineQueue: mockQueue,
    );
  });

  group('confirmPickup', () {
    test('calls api client and returns Right(null) on success', () async {
      when(() => mockApiClient.postVoid('/api/delivery/assignments/order_123/picked-up'))
          .thenAnswer((_) async {});

      final result = await repository.markPickedUp('order_123');

      expect(result is Right, isTrue);
      verify(() => mockApiClient.postVoid('/api/delivery/assignments/order_123/picked-up')).called(1);
    });

    test('enqueues to offline queue on NoConnectionFailure', () async {
      when(() => mockApiClient.postVoid('/api/delivery/assignments/order_123/picked-up'))
          .thenThrow(NoConnectionFailure());
      when(() => mockQueue.enqueue(any())).thenAnswer((_) async {});

      final result = await repository.markPickedUp('order_123');

      expect(result is Right, isTrue);
      verify(() => mockQueue.enqueue(any())).called(1);
    });
  });

  group('confirmDelivery', () {
    test('calls api client and returns Right(null) on success', () async {
      when(() => mockApiClient.postVoid('/api/delivery/assignments/order_123/delivered'))
          .thenAnswer((_) async {});

      final result = await repository.markDelivered('order_123');

      expect(result is Right, isTrue);
      verify(() => mockApiClient.postVoid('/api/delivery/assignments/order_123/delivered')).called(1);
    });

    test('enqueues to offline queue on NoConnectionFailure', () async {
      when(() => mockApiClient.postVoid('/api/delivery/assignments/order_123/delivered'))
          .thenThrow(NoConnectionFailure());
      when(() => mockQueue.enqueue(any())).thenAnswer((_) async {});

      final result = await repository.markDelivered('order_123');

      expect(result is Right, isTrue);
      verify(() => mockQueue.enqueue(any())).called(1);
    });
  });
}
