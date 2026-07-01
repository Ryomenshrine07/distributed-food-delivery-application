import 'package:flutter/foundation.dart';

import 'identity_claims.dart';

/// Represents an authenticated user session.
///
/// Contains the raw JWT [token] for API requests and the decoded
/// [claims] for display and routing decisions.
@immutable
class Session {
  const Session({
    required this.token,
    required this.claims,
  });

  /// The raw JWT token string for API `Authorization` headers.
  final String token;

  /// Decoded identity claims from the JWT.
  final IdentityClaims claims;

  /// Whether the session token has expired.
  bool get isExpired => claims.isExpired;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Session &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          claims == other.claims;

  @override
  int get hashCode => Object.hash(token, claims);

  @override
  String toString() => 'Session(claims: $claims, expired: $isExpired)';
}
