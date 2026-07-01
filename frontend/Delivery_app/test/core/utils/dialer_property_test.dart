// Feature: ui-modernization, Property 2: Dialer sanitization and launch gating
//
// Property 2: Dialer sanitization and launch gating
// For any input phone string, the sanitized number contains only digits and
// the `+` character (preserving their original relative order); a dialer launch
// is attempted if and only if the sanitized number is non-empty; and when the
// sanitized number is empty the dialer returns failure and performs no launch.
//
// The oracle for sanitization is an independent in-order character filter
// (keep only 0-9 and '+'), derived from the specification rather than the
// implementation, so equality with it proves both the "only [0-9+]" and the
// "relative order preserved" clauses. Launch gating is exercised through
// `launchDialer` with an injected recording launcher: because `launchDialer`
// performs no `await` before invoking the launcher, the launcher call (or
// absence of one) is observable synchronously within each iteration.
//
// **Validates: Requirements 6.3, 6.4**

import 'dart:async';

import 'package:delivery_app/core/utils/dialer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../support/generators.dart';
import '../../support/pbt.dart';

/// Independent oracle: keep only digit and `+` characters, in order.
String _keepDigitsAndPlus(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final isDigit = rune >= 0x30 && rune <= 0x39; // '0'..'9'
    if (isDigit || ch == '+') buffer.write(ch);
  }
  return buffer.toString();
}

/// A single recorded launch attempt.
class _LaunchCall {
  _LaunchCall(this.uri, this.mode);
  final Uri uri;
  final LaunchMode mode;
}

void main() {
  group(propertyTag(2, 'Dialer sanitization and launch gating'), () {
    test(
      'sanitization, order preservation, and launch gating hold across '
      'generated phone strings (>=100 iterations)',
      () {
        forAll<String>(
          // Phone-like strings mix digits, '+', and noise (spaces, dashes,
          // parentheses, letters), including all-noise and empty inputs, so the
          // whole sanitize/gate input space is exercised.
          Gen.phoneLike(maxLength: 20),
          (raw) {
            final sanitized = sanitizePhone(raw);

            // Req 6.3 (character set): only digits and '+' survive.
            expect(
              RegExp(r'^[0-9+]*$').hasMatch(sanitized),
              isTrue,
              reason: 'sanitized "$sanitized" must contain only [0-9+]',
            );

            // Req 6.3 (order): equals the in-order digit/`+` filter of input.
            expect(
              sanitized,
              _keepDigitsAndPlus(raw),
              reason: 'sanitization must preserve relative order',
            );

            // Req 6.4 (gating): a launch is attempted iff sanitized non-empty.
            final calls = <_LaunchCall>[];
            Future<bool> recording(
              Uri uri, {
              LaunchMode mode = LaunchMode.platformDefault,
            }) async {
              calls.add(_LaunchCall(uri, mode));
              return true;
            }

            // launchDialer invokes the launcher synchronously (no internal
            // await), so `calls` is fully populated once this returns.
            unawaited(launchDialer(raw, launcher: recording));

            if (sanitized.isEmpty) {
              expect(
                calls,
                isEmpty,
                reason: 'empty sanitized number must perform no launch',
              );
            } else {
              expect(
                calls.length,
                1,
                reason: 'non-empty sanitized number launches exactly once',
              );
              expect(calls.single.uri, Uri(scheme: 'tel', path: sanitized));
              expect(calls.single.mode, LaunchMode.externalApplication);
            }
          },
          describe: (raw) => 'raw="$raw"',
        );
      },
    );

    test('empty sanitized number returns failure and never launches', () async {
      final launched = <Uri>[];
      Future<bool> recording(
        Uri uri, {
        LaunchMode mode = LaunchMode.platformDefault,
      }) async {
        launched.add(uri);
        return true;
      }

      // Inputs that all sanitize to the empty string.
      for (final raw in const ['', '   ', 'abc', '()- .', 'no digits']) {
        final result = await launchDialer(raw, launcher: recording);
        expect(result, isFalse, reason: 'empty -> failure for "$raw"');
      }
      expect(launched, isEmpty, reason: 'no launch attempted for empty inputs');
    });
  });
}
