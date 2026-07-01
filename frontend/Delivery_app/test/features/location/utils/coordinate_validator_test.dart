import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/features/location/utils/coordinate_validator.dart';

void main() {
  group('CoordinateValidator', () {
    test('valid coordinates', () {
      expect(CoordinateValidator.isValid(0, 0), isTrue);
      expect(CoordinateValidator.isValid(90, 180), isTrue);
      expect(CoordinateValidator.isValid(-90, -180), isTrue);
      expect(CoordinateValidator.isValid(12.9716, 77.5946), isTrue);
    });

    test('invalid latitude', () {
      expect(CoordinateValidator.isValid(90.1, 0), isFalse);
      expect(CoordinateValidator.isValid(-90.1, 0), isFalse);
      expect(CoordinateValidator.isValid(100, 0), isFalse);
    });

    test('invalid longitude', () {
      expect(CoordinateValidator.isValid(0, 180.1), isFalse);
      expect(CoordinateValidator.isValid(0, -180.1), isFalse);
      expect(CoordinateValidator.isValid(0, 200), isFalse);
    });
  });
}
