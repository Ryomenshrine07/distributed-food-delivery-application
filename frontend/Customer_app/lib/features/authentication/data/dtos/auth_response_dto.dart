import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response_dto.freezed.dart';
part 'auth_response_dto.g.dart';

/// Wire mirror of the auth-service `AuthResponse` returned by
/// `POST /auth/login/customer` (Req 2).
///
/// All fields are present on a successful (200) authentication. `userId` is a
/// backend UUID serialized as a string; `role` is the backend `Role` enum
/// serialized as its name string.
@freezed
abstract class AuthResponseDto with _$AuthResponseDto {
  /// Creates an [AuthResponseDto].
  const factory AuthResponseDto({
    required String token,
    required String userId,
    required String fullName,
    required String email,
    required String role,
  }) = _AuthResponseDto;

  /// Decodes an [AuthResponseDto] from a JSON map.
  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);
}
