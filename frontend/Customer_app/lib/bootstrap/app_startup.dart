import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/authentication/domain/entities/session.dart';
import '../../features/session/session_repository_impl.dart';

part 'app_startup.g.dart';

/// Bootstrap provider that determines the app's initial auth state.
///
/// Reads the persisted session from secure storage:
/// - If a valid (non-expired) token exists → returns the [Session].
/// - If no token or expired → returns `null`.
///
/// The router's redirect guard uses this to route to `/home` or `/login`.
@Riverpod(keepAlive: true)
Future<Session?> appStartup(Ref ref) async {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return sessionRepo.currentSession();
}
