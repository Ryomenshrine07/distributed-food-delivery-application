import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/repositories/background_location_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../data/repositories/background_location_repository_impl.dart';
import '../../data/repositories/location_repository_impl.dart';

/// Posts the rider's live location heartbeats to the backend
/// (`/api/delivery/partners/{id}/location`).
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(
    ref.watch(apiClientProvider),
    ref.watch(sessionRepositoryProvider),
  );
});

final backgroundLocationRepositoryProvider =
    Provider<BackgroundLocationRepository>((ref) {
  return BackgroundLocationRepositoryImpl(
    ref.watch(locationRepositoryProvider),
  );
});
