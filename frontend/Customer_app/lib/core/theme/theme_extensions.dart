import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Convenience extensions for accessing custom theme tokens.
extension AppTokensExtension on ThemeData {
  /// Returns the [AppTokens] attached to this theme.
  AppTokens get appTokens => extension<AppTokens>()!;
}

/// Convenience extensions for accessing tokens from a [BuildContext].
extension BuildContextThemeExtension on BuildContext {
  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The current [AppTokens].
  AppTokens get appTokens => Theme.of(this).appTokens;
}
