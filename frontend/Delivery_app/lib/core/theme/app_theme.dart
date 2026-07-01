import 'package:flutter/material.dart';

import 'app_tokens.dart';
import 'brand_palette.dart';

class AppTheme {
  AppTheme._();

  /// Brand seed color used to generate the color scheme (shared with the
  /// Customer app via [BrandPalette]).
  static const Color _seedColor = BrandPalette.brandPrimary;

  static ThemeData get light => _themeData(Brightness.light, AppTokens.light());

  static ThemeData get dark => _themeData(Brightness.dark, AppTokens.dark());

  /// Builds a [ThemeData] for the given [brightness], seeding the color scheme
  /// from [_seedColor], attaching [tokens], the shared [TextTheme] ramp, and
  /// component themes derived from tokens.
  static ThemeData _themeData(Brightness brightness, AppTokens tokens) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    final textTheme = _buildTextTheme(colorScheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      textTheme: textTheme,
      extensions: [tokens],
      cardTheme: CardThemeData(
        elevation: tokens.elevationSm,
        clipBehavior: Clip.antiAlias,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: EdgeInsets.symmetric(horizontal: tokens.space24),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: EdgeInsets.symmetric(horizontal: tokens.space24),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.space16,
          vertical: tokens.space16,
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
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
      ),
      dividerTheme: DividerThemeData(
        space: tokens.space16,
        thickness: 1,
      ),
    );
  }

  /// Builds the shared, scalable [TextTheme] ramp using the color scheme's
  /// `onSurface` for text color. This ramp matches the Customer app so both
  /// apps render one consistent type ramp.
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
