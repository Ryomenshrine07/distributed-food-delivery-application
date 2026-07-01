import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/offline_queue/offline_queue.dart';
import '../../../../core/offline_queue/offline_queue_impl.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/assignment_repository_impl.dart';
import '../../domain/entities/delivery_assignment.dart';
import '../../domain/entities/delivery_status.dart';
import '../../domain/repositories/assignment_repository.dart';
import '../../domain/usecases/confirm_usecases.dart';

part 'assignment_providers.g.dart';

@riverpod
AssignmentRepository assignmentRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  final offlineQueue = ref.watch(offlineQueueProvider);
  return AssignmentRepositoryImpl(
    apiClient: ApiClient(dio),
    prefs: prefs,
    offlineQueue: offlineQueue,
  );
}

@riverpod
ConfirmPickupUseCase confirmPickupUseCase(Ref ref) {
  return ConfirmPickupUseCase(ref.watch(assignmentRepositoryProvider));
}

@riverpod
ConfirmDeliveryUseCase confirmDeliveryUseCase(Ref ref) {
  return ConfirmDeliveryUseCase(ref.watch(assignmentRepositoryProvider));
}

// Providers for SharedPreferences and OfflineQueue — can be overridden in tests
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final offlineQueueProvider = Provider<OfflineQueue>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OfflineQueueImpl(prefs);
});

@riverpod
class AssignmentController extends _$AssignmentController {
  late AssignmentRepository _repository;

  @override
  Future<DeliveryAssignment?> build() async {
    _repository = ref.watch(assignmentRepositoryProvider);
    return _repository.getActiveAssignment();
  }

  /// Cache a new assignment (from FCM push or test).
  Future<void> receiveAssignment(DeliveryAssignment assignment) async {
    await _repository.cacheAssignment(assignment);
    state = AsyncValue.data(assignment);
  }

  Future<String?> confirmPickup() async {
    final current = state.value;
    if (current == null) return 'No active assignment';

    // Loading guard — prevent double tap
    state = const AsyncValue.loading();

    final useCase = ref.read(confirmPickupUseCaseProvider);
    final result = await useCase.execute(current.orderId);

    return result.fold(
      (failure) {
        state = AsyncValue.data(current); // restore
        return failure.message;
      },
      (_) {
        final updated = current.copyWith(
          status: DeliveryStatus.pickedUp,
          pickedUpAt: DateTime.now(),
        );
        state = AsyncValue.data(updated);
        return null; // success
      },
    );
  }

  Future<String?> confirmDelivery() async {
    final current = state.value;
    if (current == null) return 'No active assignment';

    state = const AsyncValue.loading();

    final useCase = ref.read(confirmDeliveryUseCaseProvider);
    final result = await useCase.execute(current.orderId);

    return result.fold(
      (failure) {
        state = AsyncValue.data(current);
        return failure.message;
      },
      (_) {
        final updated = current.copyWith(
          status: DeliveryStatus.delivered,
          deliveredAt: DateTime.now(),
        );
        state = AsyncValue.data(updated);
        return null; // success
      },
    );
  }

  Future<String?> acceptOffer(DeliveryAssignment offer) async {
    state = const AsyncValue.loading();
    final result = await _repository.acceptOffer(offer.orderId);
    
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (_) async {
        final accepted = offer.copyWith(
          status: DeliveryStatus.assigned,
          assignedAt: DateTime.now(),
        );
        await _repository.cacheAssignment(accepted);
        state = AsyncValue.data(accepted);
        return null;
      },
    );
  }

  /// Clear the assignment after delivery is complete.
  Future<void> clearAssignment() async {
    await _repository.clearActiveAssignment();
    state = const AsyncValue.data(null);
  }
}

final pendingOffersProvider = StreamProvider.autoDispose<List<DeliveryAssignment>>((ref) async* {
  final repository = ref.watch(assignmentRepositoryProvider);
  while (true) {
    final result = await repository.getOffers();
    yield result.fold(
      (failure) => [],
      (offers) => offers,
    );
    await Future.delayed(const Duration(seconds: 5));
  }
});
