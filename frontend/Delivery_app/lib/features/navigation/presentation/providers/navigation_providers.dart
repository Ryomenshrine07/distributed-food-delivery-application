import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/navigation_repository_impl.dart';
import '../../domain/entities/route_info.dart';
import '../../domain/repositories/navigation_repository.dart';
import '../../../assignment/presentation/providers/assignment_providers.dart';
import '../../../assignment/domain/entities/delivery_status.dart';

part 'navigation_providers.g.dart';

@riverpod
NavigationRepository navigationRepository(Ref ref) {
  return NavigationRepositoryImpl();
}

enum NavigationDestination { restaurant, customer }

@riverpod
class NavigationController extends _$NavigationController {
  late NavigationRepository _repository;

  @override
  Future<RouteInfo?> build(String orderId, String destination) async {
    _repository = ref.watch(navigationRepositoryProvider);

    // Watch assignment for auto-switching destination
    final assignment = ref.watch(assignmentControllerProvider).value;
    if (assignment == null) return null;

    final dest = destination == 'restaurant'
        ? NavigationDestination.restaurant
        : NavigationDestination.customer;

    // Determine destination coordinates
    final (double lat, double lng, String label) = switch (dest) {
      NavigationDestination.restaurant => (
          assignment.restaurantLatitude,
          assignment.restaurantLongitude,
          assignment.restaurantName,
        ),
      NavigationDestination.customer => (
          assignment.customerLatitude,
          assignment.customerLongitude,
          assignment.customerName,
        ),
    };

    // For now, use a fixed origin (in real app, this comes from GPS)
    // TODO: Subscribe to LocationRepository.positionStream
    const originLat = 0.0;
    const originLng = 0.0;

    final route = await _repository.getRoute(
      const LatLng(originLat, originLng),
      LatLng(lat, lng),
    );

    return route;
  }

  Future<void> launchExternalNavigation() async {
    final assignment = ref.read(assignmentControllerProvider).value;
    if (assignment == null) return;

    final dest = ref.read(navigationControllerProvider(
      assignment.orderId,
      assignment.status == DeliveryStatus.pickedUp ? 'customer' : 'restaurant',
    ));

    final (double lat, double lng, String label) =
        assignment.status == DeliveryStatus.pickedUp
            ? (assignment.customerLatitude, assignment.customerLongitude, assignment.customerName)
            : (assignment.restaurantLatitude, assignment.restaurantLongitude, assignment.restaurantName);

    await _repository.launchExternalNav(LatLng(lat, lng), label);
  }
}
