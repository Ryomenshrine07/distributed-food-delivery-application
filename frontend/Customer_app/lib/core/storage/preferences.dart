import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences.g.dart';

/// Wrapper around [SharedPreferences] for non-sensitive client preferences.
///
/// Currently persists the selected [ThemeMode] (Req 22.1). No sensitive data
/// (tokens, passwords) is ever placed here — that belongs in secure storage.
class Preferences {
  /// Creates a [Preferences] backed by the given [SharedPreferences] instance.
  Preferences(this._prefs);

  final SharedPreferences _prefs;

  /// Storage key under which the theme mode preference is persisted.
  static const String themeModeKey = 'theme_mode';

  /// Reads the persisted [ThemeMode], defaulting to [ThemeMode.system] when no
  /// preference has been stored or the stored value is unrecognized (Req 22.2).
  ThemeMode readThemeMode() {
    final raw = _prefs.getString(themeModeKey);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  /// Persists the selected [ThemeMode] (Req 22.1).
  Future<void> writeThemeMode(ThemeMode mode) =>
      _prefs.setString(themeModeKey, mode.name);
}

/// Composition-root binding for [SharedPreferences].
///
/// Defaults to throwing because the instance must be obtained asynchronously
/// (`SharedPreferences.getInstance()`); it is overridden at the composition
/// root with the awaited instance (see `main.dart`). Tests override it after
/// `SharedPreferences.setMockInitialValues`.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) => throw UnimplementedError(
      'sharedPreferencesProvider must be overridden at the composition root '
      'with the awaited SharedPreferences instance.',
    );

/// Provides the [Preferences] wrapper backed by [sharedPreferencesProvider].
@Riverpod(keepAlive: true)
Preferences preferences(Ref ref) =>
    Preferences(ref.watch(sharedPreferencesProvider));
