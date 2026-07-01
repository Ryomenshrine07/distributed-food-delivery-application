import 'package:delivery_app/core/error/result.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_assignment.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_status.dart';
import 'package:delivery_app/features/assignment/domain/repositories/assignment_repository.dart';
import 'package:delivery_app/features/assignment/domain/usecases/confirm_usecases.dart';
import 'package:delivery_app/features/assignment/presentation/providers/assignment_providers.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAssignmentRepository extends Mock implements AssignmentRepository {}
class MockConfirmPickupUseCase extends Mock implements ConfirmPickupUseCase {}

void main() {
  late MockAssignmentRepository mockRepository;
  late MockConfirmPickupUseCase mockPickupUseCase;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockAssignmentRepository();
    mockPickupUseCase = MockConfirmPickupUseCase();

    container = ProviderContainer(
      overrides: [
        assignmentRepositoryProvider.overrideWithValue(mockRepository),
        confirmPickupUseCaseProvider.overrideWithValue(mockPickupUseCase),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  final sampleAssignment = DeliveryAssignment(
    id: 'assign_123',
    orderId: 'order_123',
    status: DeliveryStatus.assigned,
    restaurantAddress: '123 Pizza St',
    restaurantLatitude: 40.7128,
    restaurantLongitude: -74.0060,
    restaurantName: 'Pizza Place',
    customerAddress: '456 Delivery Ave',
    customerLatitude: 40.7130,
    customerLongitude: -74.0065,
    customerName: 'John Doe',
    customerPhone: '555-1234',
    itemCount: 2,
    assignedAt: DateTime.now(),
  );

  test('initial state loads active assignment from repository', () async {
    when(() => mockRepository.getActiveAssignment())
        .thenAnswer((_) async => sampleAssignment);

    final state = await container.read(assignmentControllerProvider.future);

    expect(state, sampleAssignment);
    verify(() => mockRepository.getActiveAssignment()).called(1);
  });

  test('confirmPickup transitions status to pickedUp', () async {
    when(() => mockRepository.getActiveAssignment())
        .thenAnswer((_) async => sampleAssignment);
    
    when(() => mockPickupUseCase.execute('order_123'))
        .thenAnswer((_) async => const Right(null));

    // Ensure initialization
    await container.read(assignmentControllerProvider.future);
    
    await container.read(assignmentControllerProvider.notifier).confirmPickup();

    final state = container.read(assignmentControllerProvider).value;
    expect(state?.status, DeliveryStatus.pickedUp);
    verify(() => mockPickupUseCase.execute('order_123')).called(1);
  });

  test(
      'polling clears the assignment and stops once the customer confirms '
      'receipt (getActiveAssignment returns null)', () {
    // Real timers can only be driven deterministically inside fakeAsync, so we
    // build the controller and advance the fake clock past the poll interval.
    fakeAsync((async) {
      final pickedUp = sampleAssignment.copyWith(
        status: DeliveryStatus.pickedUp,
        pickedUpAt: DateTime.now(),
      );

      // First read (initial build) sees the picked-up assignment; every later
      // poll returns null, mirroring the repository clearing its cache once the
      // order flips to DELIVERED after the customer confirms receipt.
      var calls = 0;
      when(() => mockRepository.getActiveAssignment()).thenAnswer((_) async {
        calls++;
        return calls == 1 ? pickedUp : null;
      });

      final localContainer = ProviderContainer(
        overrides: [
          assignmentRepositoryProvider.overrideWithValue(mockRepository),
          confirmPickupUseCaseProvider.overrideWithValue(mockPickupUseCase),
        ],
      );
      addTearDown(localContainer.dispose);

      // Keep the provider alive and kick off build().
      localContainer.listen(assignmentControllerProvider, (_, _) {});
      async.flushMicrotasks();

      // Initial state is the picked-up assignment; polling is now scheduled.
      expect(
        localContainer.read(assignmentControllerProvider).value,
        pickedUp,
      );
      expect(calls, 1);

      // One poll interval later the repository reports no active assignment.
      async.elapse(const Duration(seconds: 5));
      async.flushMicrotasks();

      final settled = localContainer.read(assignmentControllerProvider);
      expect(settled, isA<AsyncData<DeliveryAssignment?>>());
      expect(settled.value, isNull);
      final callsWhenCleared = calls;
      expect(callsWhenCleared, greaterThanOrEqualTo(2));

      // Polling has stopped: further elapsed time triggers no more reads.
      async.elapse(const Duration(seconds: 20));
      async.flushMicrotasks();
      expect(calls, callsWhenCleared);
    });
  });
}
