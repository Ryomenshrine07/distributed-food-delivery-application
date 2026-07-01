import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/error/failure.dart';
import '../providers/availability_providers.dart';
import '../../../location/presentation/providers/location_providers.dart';

part 'availability_controller.g.dart';

@riverpod
class AvailabilityController extends _$AvailabilityController {
  @override
  FutureOr<bool> build() async {
    final repo = ref.read(availabilityRepositoryProvider);
    // Automatically go online when logged in / initialized
    try {
      await repo.goOnline();
      ref.read(backgroundLocationRepositoryProvider).init();
      await ref.read(backgroundLocationRepositoryProvider).startService();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Failure?> toggleStatus() async {
    final currentStatus = state.hasValue ? state.value! : false;
    state = const AsyncLoading();
    
    final repo = ref.read(availabilityRepositoryProvider);
    
    if (currentStatus) {
      final result = await repo.goOffline();
      return result.fold(
        (failure) {
          state = AsyncError(failure, StackTrace.current);
          return failure;
        },
        (_) async {
          await ref.read(backgroundLocationRepositoryProvider).stopService();
          state = const AsyncData(false);
          return null;
        },
      );
    } else {
      final result = await repo.goOnline();
      return result.fold(
        (failure) {
          state = AsyncError(failure, StackTrace.current);
          return failure;
        },
        (_) async {
          ref.read(backgroundLocationRepositoryProvider).init();
          await ref.read(backgroundLocationRepositoryProvider).startService();
          state = const AsyncData(true);
          return null;
        },
      );
    }
  }
}
