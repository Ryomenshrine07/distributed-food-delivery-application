import 'package:customer_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer_app/core/storage/preferences.dart';
import 'package:customer_app/core/storage/secure_storage.dart';

void main() {
  group('App boot smoke test', () {
    testWidgets('App pumps without exceptions', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStoreProvider.overrideWithValue(SecureStorage()),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const CustomerApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the app renders without throwing.
      // If it reaches here, the smoke test passes.
    });
  });
}
