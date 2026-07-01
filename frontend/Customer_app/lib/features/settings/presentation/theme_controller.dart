import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/preferences.dart';

part 'theme_controller.g.dart';

const _kThemeModeKey = 'app_theme_mode';

/// Controls the app's theme mode (System, Light, Dark).
@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final modeStr = prefs.getString(_kThemeModeKey);
    return switch (modeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_kThemeModeKey, mode.name);
    state = mode;
  }
}
