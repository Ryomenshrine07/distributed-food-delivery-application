import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/assignment/presentation/providers/assignment_providers.dart';
import 'features/notifications/presentation/providers/notification_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Required so location samples sent from the background location task isolate
  // (via sendDataToMain) are delivered to the registered callbacks in this
  // (UI) isolate. Without this the heartbeats are silently dropped.
  FlutterForegroundTask.initCommunicationPort();

  final prefs = await SharedPreferences.getInstance();
  
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  try {
    await Firebase.initializeApp();
    final pushService = container.read(pushNotificationServiceProvider);
    await pushService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(UncontrolledProviderScope(
    container: container,
    child: const DeliveryApp(),
  ));
}
