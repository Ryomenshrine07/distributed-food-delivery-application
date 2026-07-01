import 'package:delivery_app/core/error/result.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_assignment.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_status.dart';
import 'package:delivery_app/features/assignment/domain/repositories/assignment_repository.dart';
import 'package:delivery_app/features/assignment/domain/usecases/confirm_usecases.dart';
import 'package:delivery_app/features/assignment/presentation/providers/assignment_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAssignmentRepository extends Mock implements AssignmentRepository {}
class MockConfirmPickupUseCase extends Mock implements ConfirmPickupUseCase {}
class MockConfirmDeliveryUseCase extends Mock implements ConfirmDeliveryUseCase {}

void main() {
  late MockAssignmentRepository mockRepository;
  late MockConfirmPickupUseCase mockPickupUseCase;
  late MockConfirmDeliveryUseCase mockDeliveryUseCase;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockAssignmentRepository();
    mockPickupUseCase = MockConfirmPickupUseCase();
    mockDeliveryUseCase = MockConfirmDeliveryUseCase();
    
    container = ProviderContainer(
      overrides: [
        assignmentRepositoryProvider.overrideWithValue(mockRepository),
        confirmPickupUseCaseProvider.overrideWithValue(mockPickupUseCase),
        confirmDeliveryUseCaseProvider.overrideWithValue(mockDeliveryUseCase),
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

  test('confirmDelivery transitions status to delivered', () async {
    final pickedUpAssignment = sampleAssignment.copyWith(status: DeliveryStatus.pickedUp);
    
    when(() => mockRepository.getActiveAssignment())
        .thenAnswer((_) async => pickedUpAssignment);
        
    when(() => mockDeliveryUseCase.execute('order_123'))
        .thenAnswer((_) async => const Right(null));

    // Ensure initialization
    await container.read(assignmentControllerProvider.future);
    
    await container.read(assignmentControllerProvider.notifier).confirmDelivery();

    final state = container.read(assignmentControllerProvider).value;
    expect(state?.status, DeliveryStatus.delivered);
    verify(() => mockDeliveryUseCase.execute('order_123')).called(1);
  });
}
