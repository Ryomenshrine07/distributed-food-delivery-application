import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_response_dto.freezed.dart';
part 'user_response_dto.g.dart';

@freezed
abstract class UserResponseDto with _$UserResponseDto {
  const factory UserResponseDto({
    required String id,
    required String fullName,
    required String email,
    required String phone,
    required String role,
  }) = _UserResponseDto;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserResponseDtoFromJson(json);
}
