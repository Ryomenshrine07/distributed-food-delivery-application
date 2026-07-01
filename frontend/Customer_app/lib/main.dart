import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/storage/preferences.dart';
import 'core/storage/secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Async-initialized infrastructure that must exist before the first build.
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      // Composition root: bind ports to their concrete implementations.
      overrides: [
        // Bind the network TokenStore port to the secure-storage backing.
        tokenStoreProvider.overrideWithValue(SecureStorage()),
        // Provide the awaited SharedPreferences instance for non-sensitive prefs.
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CustomerApp(),
    ),
  );
}
