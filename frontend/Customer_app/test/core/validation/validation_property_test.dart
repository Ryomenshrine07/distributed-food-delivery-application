// Feature: customer-app, Property 2
//
// Property 2: Registration and login input validation gating
// For any registration field set, the form is submittable if and only if the
// email is well-formed AND the password length is within 8-25 AND the full
// name is non-blank (not whitespace-only) AND the phone matches `^[6-9]\d{9}$`.
// For any login field set, submission is allowed if and only if the email is
// well-formed AND the password length is within 8-15.
//
// The oracle for each property is derived from how each input is CONSTRUCTED
// (ground truth) rather than from the implementation under test. Password
// validity in particular is computed directly from the generated string's
// length, so the test exercises the validators themselves and not merely that
// the submit gate is a conjunction of them. Generators deliberately emphasise
// the boundary lengths (7/8/15/16/24/25/26) and phone near-misses.
//
// **Validates: Requirements 1.1, 1.3, 2.1**

import 'dart:math';

import 'package:customer_app/core/validation/validators.dart';
import 'package:flutter_test/flutter_test.dart';

const String _alnum =
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
const String _alpha = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
const String _anyChars =
    r'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 !@#$%^&*()';

String _pick(Random rng, String alphabet, int length) => length == 0
    ? ''
    : String.fromCharCodes(
        List.generate(
          length,
          (_) => alphabet.codeUnitAt(rng.nextInt(alphabet.length)),
        ),
      );

/// Generates an `(email, isWellFormed)` pair.
(String, bool) _email(Random rng) {
  if (rng.nextBool()) {
    // Unambiguously well-formed: alphanumeric local + domain, alpha TLD.
    final local = _pick(rng, _alnum, rng.nextInt(10) + 1);
    final domain = _pick(rng, _alnum, rng.nextInt(10) + 1);
    final tld = _pick(rng, _alpha, rng.nextInt(3) + 2); // 2-4 letters
    return ('$local@$domain.$tld', true);
  }
  // Unambiguously malformed.
  const malformed = <String>[
    '', // empty
    'plainaddress', // no @ at all
    'no-at-sign.com', // no @
    '@no-local.com', // missing local part
    'user@', // missing domain
    'user@domain', // missing dot/TLD
    'user @space.com', // whitespace in local part
    'user@dom ain.com', // whitespace in domain
    'user@@double.com', // double @
    'user@.com', // empty domain label
    '@', // just @
    'spaces only here', // no @, has spaces
  ];
  return (malformed[rng.nextInt(malformed.length)], false);
}

/// Generates a password string, emphasising boundary lengths.
String _password(Random rng) {
  const boundaries = <int>[0, 1, 7, 8, 9, 14, 15, 16, 24, 25, 26, 30];
  final length =
      rng.nextBool() ? boundaries[rng.nextInt(boundaries.length)] : rng.nextInt(31);
  return _pick(rng, _anyChars, length);
}

/// Generates a `(fullName, isNonBlank)` pair.
(String, bool) _name(Random rng) {
  switch (rng.nextInt(4)) {
    case 0:
      return ('', false); // empty
    case 1:
      const whitespace = [' ', '   ', '\t', '\n', ' \t\n ', '\t  \n'];
      return (whitespace[rng.nextInt(whitespace.length)], false);
    case 2:
      // Real content padded with surrounding whitespace -> still non-blank.
      final core = _pick(rng, _alpha, rng.nextInt(8) + 1);
      return ('  $core \t', true);
    default:
      return (_pick(rng, _alpha, rng.nextInt(12) + 1), true);
  }
}

/// Generates a `(phone, matchesPattern)` pair for `^[6-9]\d{9}$`.
(String, bool) _phone(Random rng) {
  String nineDigits() => List.generate(9, (_) => rng.nextInt(10)).join();

  if (rng.nextBool()) {
    final first = 6 + rng.nextInt(4); // 6,7,8,9
    return ('$first${nineDigits()}', true);
  }

  switch (rng.nextInt(6)) {
    case 0:
      // Leading digit 0-5 (wrong range) but otherwise 10 digits.
      final first = rng.nextInt(6);
      return ('$first${nineDigits()}', false);
    case 1:
      // Too short: valid leading digit but only 9 total digits.
      final first = 6 + rng.nextInt(4);
      final rest = List.generate(8, (_) => rng.nextInt(10)).join();
      return ('$first$rest', false);
    case 2:
      // Too long: 11 digits.
      final first = 6 + rng.nextInt(4);
      final rest = List.generate(10, (_) => rng.nextInt(10)).join();
      return ('$first$rest', false);
    case 3:
      // Correct length (10) but contains a non-digit.
      final first = 6 + rng.nextInt(4);
      final rest = List.generate(8, (_) => rng.nextInt(10)).join();
      return ('$first${rest}x', false);
    case 4:
      return ('', false); // empty
    default:
      return ('98765abcde', false); // letters in the tail
  }
}

void main() {
  group('Property 2: registration and login validation gating', () {
    test(
      'registration is submittable iff email valid AND password 8-25 AND '
      'name non-blank AND phone matches, across >=100 iterations',
      () {
        final rng = Random(20240602); // fixed seed for reproducibility
        const iterations = 200; // exceeds the >=100 requirement

        for (var i = 0; i < iterations; i++) {
          final (email, emailValid) = _email(rng);
          final password = _password(rng);
          final (name, nameNonBlank) = _name(rng);
          final (phone, phoneMatches) = _phone(rng);

          // Ground-truth oracle, independent of the implementation.
          final passwordOk = password.length >= 8 && password.length <= 25;
          final expected =
              emailValid && passwordOk && nameNonBlank && phoneMatches;

          final actual = canSubmitRegistration(
            email: email,
            password: password,
            fullName: name,
            phone: phone,
          );

          expect(
            actual,
            expected,
            reason: 'iteration $i: email="$email"(valid=$emailValid) '
                'pwdLen=${password.length} name="$name"(nonBlank=$nameNonBlank) '
                'phone="$phone"(matches=$phoneMatches)',
          );
        }
      },
    );

    test(
      'login is submittable iff email valid AND password 8-15, '
      'across >=100 iterations',
      () {
        final rng = Random(78901234); // distinct fixed seed
        const iterations = 200; // exceeds the >=100 requirement

        for (var i = 0; i < iterations; i++) {
          final (email, emailValid) = _email(rng);
          final password = _password(rng);

          // Ground-truth oracle, independent of the implementation.
          final passwordOk = password.length >= 8 && password.length <= 15;
          final expected = emailValid && passwordOk;

          final actual = canSubmitLogin(email: email, password: password);

          expect(
            actual,
            expected,
            reason: 'iteration $i: email="$email"(valid=$emailValid) '
                'pwdLen=${password.length}',
          );
        }
      },
    );
  });
}
