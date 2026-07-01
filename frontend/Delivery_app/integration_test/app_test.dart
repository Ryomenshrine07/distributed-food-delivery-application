import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:delivery_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('tap on the login button',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Find the email field and enter text
      final emailField = find.bySemanticsLabel('Email');
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, 'vupadhyay382@gmail.com');
        await tester.pumpAndSettle();
      }

      // Find the password field and enter text
      final passwordField = find.bySemanticsLabel('Password');
      if (passwordField.evaluate().isNotEmpty) {
        await tester.enterText(passwordField, 'password123');
        await tester.pumpAndSettle();
      }

      // Verify if there is a login button and tap it
      final loginButton = find.byType(ElevatedButton);
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton.first);
        await tester.pumpAndSettle();
      }
    });
  });
}
