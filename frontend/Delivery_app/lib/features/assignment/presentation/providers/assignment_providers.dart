import 'dart:async';

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

  /// Periodic re-check of the active assignment. This is what lets the rider's
  /// app notice that the CUSTOMER confirmed receipt: once the order flips to
  /// DELIVERED/CANCELLED, [AssignmentRepository.getActiveAssignment] clears the
  /// local cache and returns null, so a tick surfaces that null into [state]
  /// and the UI can complete. Null whenever no non-terminal assignment is live.
  Timer? _pollTimer;

  /// True while a tick is awaiting the repository, so a slow request never
  /// stacks up overlapping ticks behind the 5s cadence.
  bool _isPolling = false;

  /// Flipped in [Ref.onDispose]; a tick that resolves after disposal must not
  /// write to [state] (that would throw).
  bool _disposed = false;

  /// Poll cadence — matches the existing `pendingOffersProvider`.
  static const Duration _pollInterval = Duration(seconds: 5);

  @override
  Future<DeliveryAssignment?> build() async {
    _repository = ref.watch(assignmentRepositoryProvider);

    // The notifier instance is reused across recomputes, so reset the dispose
    // latch each build; onDispose cancels any timer from a previous build (and
    // stops in-flight ticks from writing state after the provider is gone).
    _disposed = false;
    ref.onDispose(() {
      _disposed = true;
      _pollTimer?.cancel();
      _pollTimer = null;
    });

    final assignment = await _repository.getActiveAssignment();
    _syncPolling(assignment);
    return assignment;
  }

  /// Starts the poll timer when [assignment] is a live, non-terminal delivery
  /// and stops it otherwise (null or delivered). Idempotent: an already-running
  /// timer is left in place so the cadence stays steady across state changes.
  void _syncPolling(DeliveryAssignment? assignment) {
    final shouldPoll =
        assignment != null && assignment.status != DeliveryStatus.delivered;
    if (shouldPoll) {
      _pollTimer ??= Timer.periodic(_pollInterval, (_) => _poll());
    } else {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  /// One poll tick. Skips while a previous tick is in flight, while a mutation
  /// (confirmPickup/acceptOffer) is loading — so an optimistic state is never
  /// clobbered — and after disposal. Pushes the freshly read assignment into
  /// [state] and stops polling once it is null (order completed/cancelled) or
  /// delivered.
  Future<void> _poll() async {
    if (_isPolling || _disposed || state.isLoading) return;
    _isPolling = true;
    try {
      final latest = await _repository.getActiveAssignment();
      if (_disposed) return;
      state = AsyncValue.data(latest);
      _syncPolling(latest);
    } finally {
      _isPolling = false;
    }
  }

  /// Cache a new assignment (from FCM push or test).
  Future<void> receiveAssignment(DeliveryAssignment assignment) async {
    await _repository.cacheAssignment(assignment);
    state = AsyncValue.data(assignment);
    _syncPolling(assignment);
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
        _syncPolling(current);
        return failure.message;
      },
      (_) {
        final updated = current.copyWith(
          status: DeliveryStatus.pickedUp,
          pickedUpAt: DateTime.now(),
        );
        state = AsyncValue.data(updated);
        _syncPolling(updated);
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
        _syncPolling(null);
        return failure.message;
      },
      (_) async {
        final accepted = offer.copyWith(
          status: DeliveryStatus.assigned,
          assignedAt: DateTime.now(),
        );
        await _repository.cacheAssignment(accepted);
        state = AsyncValue.data(accepted);
        _syncPolling(accepted);
        return null;
      },
    );
  }

  /// Clear the assignment after delivery is complete.
  Future<void> clearAssignment() async {
    await _repository.clearActiveAssignment();
    state = const AsyncValue.data(null);
    _syncPolling(null);
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
