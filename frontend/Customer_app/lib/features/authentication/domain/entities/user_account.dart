import 'package:flutter/foundation.dart';

/// A registered user account returned after successful registration.
///
/// Maps from the backend `UserResponse` DTO (Req 1).
@immutable
class UserAccount {
  const UserAccount({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  /// The user's unique identifier (UUID string).
  final String id;

  /// The user's full name.
  final String fullName;

  /// The user's email address.
  final String email;

  /// The user's phone number.
  final String phone;

  /// The user's role (e.g. `CUSTOMER`).
  final String role;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAccount &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => Object.hash(id, email);

  @override
  String toString() =>
      'UserAccount(id: $id, fullName: $fullName, email: $email)';
}
