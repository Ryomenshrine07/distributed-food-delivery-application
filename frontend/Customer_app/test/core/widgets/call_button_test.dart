// Widget tests for CallButton (the tappable call action wired into the tracking
// screen). The url_launcher boundary is mocked via the injectable `launcher`
// so no real platform channel is touched.
//
//  - disabled when there is no dialable phone number        (Req 6.6)
//  - dials the sanitized number on tap                       (Req 6.1, 6.2)
//  - floating SnackBar shown when the launch fails           (Req 6.5)
//  - no SnackBar when the launch succeeds
//  - "Call" tooltip/label and a >=48x48 tap target           (Req 9.1, 9.2)

import 'package:customer_app/core/widgets/call_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

/// Records launch attempts and returns a canned [result], standing in for the
/// real url_launcher boundary.
class _FakeLauncher {
  _FakeLauncher(this.result);
  final bool result;
  final List<Uri> calls = [];

  Future<bool> call(Uri uri, {LaunchMode mode = LaunchMode.platformDefault}) async {
    calls.add(uri);
    return result;
  }
}

Widget _harness(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('is disabled when there is no phone number (Req 6.6)',
      (tester) async {
    await tester.pumpWidget(_harness(const CallButton(phoneNumber: null)));

    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
  });

  testWidgets('is disabled when the number has no dialable characters',
      (tester) async {
    await tester.pumpWidget(_harness(const CallButton(phoneNumber: 'abc - ()')));

    expect(tester.widget<IconButton>(find.byType(IconButton)).onPressed, isNull);
  });

  testWidgets('dials the sanitized number on tap (Req 6.1)', (tester) async {
    final fake = _FakeLauncher(true);
    await tester.pumpWidget(
      _harness(CallButton(phoneNumber: '+1 (555) 010-2020', launcher: fake.call)),
    );

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(fake.calls, hasLength(1));
    expect(fake.calls.single, Uri(scheme: 'tel', path: '+15550102020'));
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('shows a floating SnackBar when the launch fails (Req 6.5)',
      (tester) async {
    final fake = _FakeLauncher(false);
    await tester.pumpWidget(
      _harness(CallButton(phoneNumber: '5550102020', launcher: fake.call)),
    );

    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    expect(find.text("Couldn't open the dialer"), findsOneWidget);
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).behavior,
      SnackBarBehavior.floating,
    );

    // Drain the SnackBar's auto-dismiss timer before teardown.
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('exposes a "Call" tooltip and a >=48x48 tap target (Req 9.1/9.2)',
      (tester) async {
    await tester.pumpWidget(_harness(const CallButton(phoneNumber: '5550102020')));

    expect(find.byTooltip('Call'), findsOneWidget);
    final size = tester.getSize(find.byType(IconButton));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
