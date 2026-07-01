import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/features/authentication/data/dtos/auth_response_dto.dart';
import 'package:delivery_app/features/authentication/data/dtos/user_response_dto.dart';

void main() {
  group('Authentication DTOs', () {
    test('AuthResponseDto serialization cycle', () {
      const dto = AuthResponseDto(
        token: 'test-token',
        userId: '123-456',
        fullName: 'John Doe',
        email: 'john@example.com',
        role: 'DELIVERY_PARTNER',
      );
      
      final json = dto.toJson();
      final fromJson = AuthResponseDto.fromJson(json);
      
      expect(fromJson, dto);
    });

    test('UserResponseDto serialization cycle', () {
      const dto = UserResponseDto(
        id: '123-456',
        fullName: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        role: 'DELIVERY_PARTNER',
      );
      
      final json = dto.toJson();
      final fromJson = UserResponseDto.fromJson(json);
      
      expect(fromJson, dto);
    });
  });
}
