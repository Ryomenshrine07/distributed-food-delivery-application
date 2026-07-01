import '../../domain/entities/user.dart';
import '../dtos/user_response_dto.dart';
import '../dtos/auth_response_dto.dart';

extension UserResponseDtoMapper on UserResponseDto {
  User toDomain() {
    return User(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
    );
  }
}

extension AuthResponseDtoMapper on AuthResponseDto {
  User toDomain() {
    return User(
      id: userId,
      fullName: fullName,
      email: email,
      phone: '', // AuthResponse doesn't have phone, this is a gap we should handle appropriately
      role: role,
    );
  }
}

extension UserMapper on User {
  UserResponseDto toDto() {
    return UserResponseDto(
      id: id,
      fullName: fullName,
      email: email,
      phone: phone,
      role: role,
    );
  }
}
