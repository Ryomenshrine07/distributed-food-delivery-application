import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../authentication/domain/entities/identity_claims.dart';
import '../../session/session_repository_impl.dart';

part 'profile_controller.g.dart';

/// Provides the current user's identity claims for the profile screen.
@riverpod
IdentityClaims? profileClaims(Ref ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  return sessionRepo.claims();
}
