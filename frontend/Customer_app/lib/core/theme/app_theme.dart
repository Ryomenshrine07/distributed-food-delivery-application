import 'package:flutter/material.dart';

import 'app_tokens.dart';
import 'brand_palette.dart';

/// Builds Material 3 light and dark [ThemeData] from a shared seed color
/// with [AppTokens] attached as a [ThemeExtension].
class AppTheme {
  AppTheme._();

  /// Brand seed color used to generate the color scheme.
  static const Color seedColor = BrandPalette.brandPrimary;

  /// Creates the light [ThemeData].
  static ThemeData light() => _themeData(Brightness.light, AppTokens.light);

  /// Creates the dark [ThemeData].
  static ThemeData dark() => _themeData(Brightness.dark, AppTokens.dark);

  /// Builds a [ThemeData] for the given [brightness], seeding the color scheme
  /// from [seedColor] and wiring component themes from [tokens].
  static ThemeData _themeData(Brightness brightness, AppTokens tokens) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        elevation: tokens.elevationLevel1,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd,
          vertical: tokens.spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusPill),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
      ),
      dividerTheme: DividerThemeData(
        space: tokens.spaceMd,
        thickness: 1,
      ),
      extensions: <ThemeExtension<dynamic>>[
        tokens,
      ],
    );
  }

  /// Builds a scalable [TextTheme] using the color scheme's `onSurface`
  /// for body text to ensure proper contrast on `surface` backgrounds.
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final onSurface = colorScheme.onSurface;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        color: onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: onSurface,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: onSurface,
      ),
    );
  }
}
