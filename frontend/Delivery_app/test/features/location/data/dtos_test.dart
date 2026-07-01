import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/features/location/data/dtos/location_update_request_dto.dart';

void main() {
  group('Location DTOs', () {
    test('LocationUpdateRequestDto serialization cycle', () {
      const dto = LocationUpdateRequestDto(
        latitude: 12.9716,
        longitude: 77.5946,
      );
      
      final json = dto.toJson();
      final fromJson = LocationUpdateRequestDto.fromJson(json);
      
      expect(fromJson, dto);
    });
  });
}
