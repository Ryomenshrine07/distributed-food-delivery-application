import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_response_dto.freezed.dart';
part 'user_response_dto.g.dart';

/// Wire mirror of the auth-service `UserResponse` returned by
/// `POST /auth/register/customer` (Req 1).
///
/// `id` is a backend UUID serialized as a string; `role` is the backend `Role`
/// enum serialized as its name string. All fields are present on a successful
/// (201) registration.
@freezed
abstract class UserResponseDto with _$UserResponseDto {
  /// Creates a [UserResponseDto].
  const factory UserResponseDto({
    required String id,
    required String fullName,
    required String email,
    required String phone,
    required String role,
  }) = _UserResponseDto;

  /// Decodes a [UserResponseDto] from a JSON map.
  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);
}
