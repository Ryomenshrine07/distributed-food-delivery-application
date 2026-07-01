import 'package:flutter/foundation.dart';

/// Decoded JWT identity claims used throughout the app for display and routing.
///
/// Extracted from the JWT payload by [SessionRepository]. These claims drive
/// the profile screen, order display, and the startup route decision (Req 3.4).
@immutable
class IdentityClaims {
  const IdentityClaims({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
    this.phone,
    required this.exp,
  });

  /// The user's unique identifier (UUID string from JWT `sub` or `userId`).
  final String id;

  /// The user's email address.
  final String email;

  /// The user's role (e.g. `CUSTOMER`).
  final String role;

  /// The user's full name.
  final String name;

  /// The user's phone number (may be absent from JWT).
  final String? phone;

  /// Token expiry as a UTC [DateTime].
  final DateTime exp;

  /// Whether the token has expired.
  bool get isExpired => DateTime.now().toUtc().isAfter(exp);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdentityClaims &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          role == other.role &&
          name == other.name &&
          phone == other.phone &&
          exp == other.exp;

  @override
  int get hashCode => Object.hash(id, email, role, name, phone, exp);

  @override
  String toString() =>
      'IdentityClaims(id: $id, email: $email, role: $role, name: $name)';
}
