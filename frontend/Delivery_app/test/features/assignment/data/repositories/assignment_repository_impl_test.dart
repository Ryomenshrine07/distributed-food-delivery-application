import 'package:delivery_app/core/error/failure.dart';
import 'package:delivery_app/core/error/result.dart';
import 'package:delivery_app/core/network/api_client.dart';
import 'package:delivery_app/core/offline_queue/offline_queue.dart';
import 'package:delivery_app/core/offline_queue/pending_confirmation.dart';
import 'package:delivery_app/features/assignment/data/repositories/assignment_repository_impl.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_status.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockOfflineQueue extends Mock implements OfflineQueue {}

/// Builds a Dio [Response] for a stubbed [ApiClient.get] call.
Response<dynamic> _response(String path, {dynamic data, int statusCode = 200}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    data: data,
    statusCode: statusCode,
  );
}

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

  group('getActiveAssignment recovery (reinstall fallback)', () {
    // The bare assignment the backend returns from GET
    // /api/delivery/assignments/current for an ASSIGNED delivery.
    final currentAssignmentJson = {
      'id': 'assign_1',
      'orderId': 'order_1',
      'restaurantLatitude': 12.34,
      'restaurantLongitude': 56.78,
      'status': 'ASSIGNED',
      'assignedAt': '2024-01-01T10:00:00.000Z',
    };

    // Enrichment sources reused from the getOffers join.
    final orderJson = {
      'restaurantId': 'rest_1',
      'customerName': 'Alice',
      'customerPhone': '+15551112222',
      'deliveryLocation': {
        'address': '1 Main St',
        'latitude': 1.1,
        'longitude': 2.2,
      },
      'items': [
        {'x': 1},
        {'x': 2},
      ],
    };
    final restaurantJson = {
      'data': {'name': 'Pizza Place', 'address': '99 Food Ave'},
    };

    test(
        'when cache is empty and /current returns an ASSIGNED assignment, '
        'returns the enriched assignment and caches it', () async {
      // Cache empty — simulates local storage wiped by a reinstall.
      when(() => mockPrefs.getString('active_assignment')).thenReturn(null);

      when(() => mockApiClient.get('/api/delivery/assignments/current'))
          .thenAnswer((_) async => _response(
                '/api/delivery/assignments/current',
                data: currentAssignmentJson,
                statusCode: 200,
              ));
      when(() => mockApiClient.get('/orders/order_1')).thenAnswer(
          (_) async => _response('/orders/order_1', data: orderJson));
      when(() => mockApiClient.get('/restaurants/rest_1')).thenAnswer(
          (_) async => _response('/restaurants/rest_1', data: restaurantJson));
      when(() => mockPrefs.setString(any(), any()))
          .thenAnswer((_) async => true);

      final result = await repository.getActiveAssignment();

      expect(result, isNotNull);
      expect(result!.orderId, 'order_1');
      expect(result.status, DeliveryStatus.assigned);
      // Enriched from the order/restaurant joins.
      expect(result.customerName, 'Alice');
      expect(result.customerPhone, '+15551112222');
      expect(result.customerAddress, '1 Main St');
      expect(result.itemCount, 2);
      expect(result.restaurantName, 'Pizza Place');
      expect(result.restaurantAddress, '99 Food Ave');

      // The recovered assignment is cached for subsequent reads.
      verify(() => mockPrefs.setString('active_assignment', any())).called(1);
    });

    test('when cache is empty and /current returns 204, returns null and does not cache',
        () async {
      when(() => mockPrefs.getString('active_assignment')).thenReturn(null);
      when(() => mockApiClient.get('/api/delivery/assignments/current'))
          .thenAnswer((_) async => _response(
                '/api/delivery/assignments/current',
                data: null,
                statusCode: 204,
              ));

      final result = await repository.getActiveAssignment();

      expect(result, isNull);
      verifyNever(() => mockPrefs.setString(any(), any()));
    });
  });
}
