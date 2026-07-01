import 'package:delivery_app/features/assignment/domain/entities/delivery_assignment.dart';
import 'package:delivery_app/features/assignment/domain/entities/delivery_status.dart';
import 'package:delivery_app/features/assignment/presentation/providers/assignment_providers.dart';
import 'package:delivery_app/features/navigation/domain/entities/route_info.dart';
import 'package:delivery_app/features/navigation/domain/repositories/navigation_repository.dart';
import 'package:delivery_app/features/navigation/presentation/providers/navigation_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNavigationRepository extends Mock implements NavigationRepository {}

class FakeLatLng extends Fake implements LatLng {}

void main() {
  late MockNavigationRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeLatLng());
  });

  setUp(() {
    mockRepository = MockNavigationRepository();
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

  test('NavigationController calculates route to restaurant when assigned', () async {
    container = ProviderContainer(
      overrides: [
        navigationRepositoryProvider.overrideWithValue(mockRepository),
        // Mock assignment provider to return assigned state
        assignmentControllerProvider.overrideWith(() {
          return _MockAssignmentController(sampleAssignment);
        }),
      ],
    );

    final expectedRoute = const RouteInfo(
      distanceKm: 5.0,
      estimatedTime: Duration(minutes: 10),
      polylinePoints: [],
    );

    when(() => mockRepository.getRoute(any(), any()))
        .thenAnswer((_) async => expectedRoute);

    final provider = navigationControllerProvider('order_123', 'restaurant');
    final subscription = container.listen(provider, (_, __) {});

    final route = await container.read(provider.future);
    subscription.close();

    expect(route, expectedRoute);
    final captured = verify(() => mockRepository.getRoute(any(), captureAny())).captured;
    final LatLng destination = captured.first as LatLng;
    expect(destination.latitude, 40.7128);
  });

  test('NavigationController calculates route to customer when picked up', () async {
    final pickedUpAssignment = sampleAssignment.copyWith(status: DeliveryStatus.pickedUp);

    container = ProviderContainer(
      overrides: [
        navigationRepositoryProvider.overrideWithValue(mockRepository),
        assignmentControllerProvider.overrideWith(() {
          return _MockAssignmentController(pickedUpAssignment);
        }),
      ],
    );

    final expectedRoute = const RouteInfo(
      distanceKm: 2.0,
      estimatedTime: Duration(minutes: 5),
      polylinePoints: [],
    );

    when(() => mockRepository.getRoute(any(), any()))
        .thenAnswer((_) async => expectedRoute);

    final provider = navigationControllerProvider('order_123', 'customer');
    final subscription = container.listen(provider, (_, __) {});

    final route = await container.read(provider.future);
    subscription.close();

    expect(route, expectedRoute);
    final captured = verify(() => mockRepository.getRoute(any(), captureAny())).captured;
    final LatLng destination = captured.first as LatLng;
    expect(destination.latitude, 40.7130);
  });
}

class _MockAssignmentController extends AssignmentController {
  final DeliveryAssignment assignment;
  _MockAssignmentController(this.assignment);

  @override
  Future<DeliveryAssignment?> build() async {
    return assignment;
  }
}
