import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns error for empty or null', () {
        expect(Validators.email(null), 'Email is required');
        expect(Validators.email(''), 'Email is required');
      });

      test('returns error for invalid email', () {
        expect(Validators.email('invalid'), 'Enter a valid email address');
        expect(Validators.email('test@'), 'Enter a valid email address');
        expect(Validators.email('test@test'), 'Enter a valid email address');
      });

      test('returns null for valid email', () {
        expect(Validators.email('test@example.com'), isNull);
        expect(Validators.email('a.b@c.co'), isNull);
      });
    });

    group('phone', () {
      test('returns error for empty or null', () {
        expect(Validators.phone(null), 'Phone number is required');
        expect(Validators.phone(''), 'Phone number is required');
      });

      test('returns error for invalid phone', () {
        expect(Validators.phone('123'), 'Enter a valid 10-digit phone number');
        expect(Validators.phone('12345678901'), 'Enter a valid 10-digit phone number');
        expect(Validators.phone('abcdefghij'), 'Enter a valid 10-digit phone number');
      });

      test('returns null for valid 10-digit phone', () {
        expect(Validators.phone('1234567890'), isNull);
      });
    });

    group('otp', () {
      test('returns error for empty or null', () {
        expect(Validators.otp(null), 'OTP is required');
        expect(Validators.otp(''), 'OTP is required');
      });

      test('returns error for invalid otp', () {
        expect(Validators.otp('12345'), 'Enter a valid 6-digit OTP');
        expect(Validators.otp('1234567'), 'Enter a valid 6-digit OTP');
        expect(Validators.otp('abcdef'), 'Enter a valid 6-digit OTP');
      });

      test('returns null for valid 6-digit otp', () {
        expect(Validators.otp('123456'), isNull);
      });
    });
  });
}
