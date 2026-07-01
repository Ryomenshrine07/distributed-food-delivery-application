import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../domain/repositories/availability_repository.dart';
import '../../data/repositories/availability_repository_impl.dart';

final availabilityRepositoryProvider = Provider<AvailabilityRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return AvailabilityRepositoryImpl(apiClient, sessionRepo);
});
