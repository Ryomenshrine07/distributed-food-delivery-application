import 'package:jwt_decoder/jwt_decoder.dart';

import '../../domain/entities/identity_claims.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/user_account.dart';
import '../dtos/auth_response_dto.dart';
import '../dtos/user_response_dto.dart';

/// Maps authentication DTOs to domain entities.
class AuthMapper {
  const AuthMapper._();

  /// Maps an [AuthResponseDto] (login response) to a [Session].
  ///
  /// Decodes the JWT to extract identity claims and expiry.
  static Session sessionFromDto(AuthResponseDto dto) {
    final decoded = JwtDecoder.decode(dto.token);
    final exp = _extractExpiry(decoded);

    final claims = IdentityClaims(
      id: dto.userId,
      email: dto.email,
      role: dto.role,
      name: dto.fullName,
      phone: decoded['phone'] as String?,
      exp: exp,
    );

    return Session(token: dto.token, claims: claims);
  }

  /// Maps a [UserResponseDto] (registration response) to a [UserAccount].
  static UserAccount userAccountFromDto(UserResponseDto dto) {
    return UserAccount(
      id: dto.id,
      fullName: dto.fullName,
      email: dto.email,
      phone: dto.phone,
      role: dto.role,
    );
  }

  /// Decodes [IdentityClaims] directly from a raw JWT token string.
  ///
  /// Used at app startup to reconstruct claims from a persisted token.
  static IdentityClaims? claimsFromToken(String token) {
    try {
      final decoded = JwtDecoder.decode(token);
      final exp = _extractExpiry(decoded);

      return IdentityClaims(
        id: (decoded['userId'] ?? decoded['sub'] ?? '') as String,
        email: (decoded['email'] ?? decoded['sub'] ?? '') as String,
        role: (decoded['role'] ?? '') as String,
        name: (decoded['fullName'] ?? decoded['name'] ?? '') as String,
        phone: decoded['phone'] as String?,
        exp: exp,
      );
    } catch (_) {
      return null;
    }
  }

  /// Extracts the expiry [DateTime] from a decoded JWT payload.
  static DateTime _extractExpiry(Map<String, dynamic> decoded) {
    final expValue = decoded['exp'];
    if (expValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        expValue * 1000,
        isUtc: true,
      );
    }
    // Fallback: treat as already expired if we can't parse.
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
