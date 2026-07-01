import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/session_repository.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../domain/entities/partner_session.dart';

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final tokenStore = ref.watch(tokenStoreProvider);
  final authEventSink = ref.watch(authEventSinkProvider);
  return SessionRepositoryImpl(tokenStore, authEventSink);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return AuthRepositoryImpl(apiClient, sessionRepo);
});

final sessionProvider = StreamProvider<PartnerSession?>((ref) async* {
  final repo = ref.watch(sessionRepositoryProvider);
  yield repo.currentSession;
  yield* repo.sessionChanges;
});
