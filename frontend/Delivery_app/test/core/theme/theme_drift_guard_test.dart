// Theme drift-guard test — Requirements 8.6
//
// Asserts that the ColorScheme seed and key AppTokens values equal the
// documented BrandPalette constants, so the theme cannot silently drift away
// from the design's canonical, documented color system.

import 'package:delivery_app/core/theme/app_theme.dart';
import 'package:delivery_app/core/theme/app_tokens.dart';
import 'package:delivery_app/core/theme/brand_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Theme drift guard (Req 8.6)', () {
    test('light ColorScheme is seeded from BrandPalette.brandPrimary', () {
      final expected = ColorScheme.fromSeed(
        seedColor: BrandPalette.brandPrimary,
        brightness: Brightness.light,
      );
      expect(AppTheme.light.colorScheme, expected);
    });

    test('dark ColorScheme is seeded from BrandPalette.brandPrimary', () {
      final expected = ColorScheme.fromSeed(
        seedColor: BrandPalette.brandPrimary,
        brightness: Brightness.dark,
      );
      expect(AppTheme.dark.colorScheme, expected);
    });

    test('light token marker + semantic values match BrandPalette', () {
      final tokens = AppTokens.light();
      expect(tokens.primary, BrandPalette.brandPrimary);
      expect(tokens.riderMarker, BrandPalette.riderMarker);
      expect(tokens.customerMarker, BrandPalette.customerMarker);
      expect(tokens.restaurantMarker, BrandPalette.restaurantMarker);
      expect(tokens.success, BrandPalette.successLight);
      expect(tokens.warning, BrandPalette.warningLight);
      expect(tokens.error, BrandPalette.errorLight);
      expect(tokens.info, BrandPalette.infoLight);
    });

    test('dark token marker + semantic values match BrandPalette', () {
      final tokens = AppTokens.dark();
      expect(tokens.primary, BrandPalette.brandPrimary);
      expect(tokens.riderMarker, BrandPalette.riderMarker);
      expect(tokens.customerMarker, BrandPalette.customerMarker);
      expect(tokens.restaurantMarker, BrandPalette.restaurantMarker);
      expect(tokens.success, BrandPalette.successDark);
      expect(tokens.warning, BrandPalette.warningDark);
      expect(tokens.error, BrandPalette.errorDark);
      expect(tokens.info, BrandPalette.infoDark);
    });

    test('attached theme extension exposes documented marker tokens', () {
      final tokens = AppTheme.light.extension<AppTokens>()!;
      expect(tokens.riderMarker, BrandPalette.riderMarker);
      expect(tokens.customerMarker, BrandPalette.customerMarker);
      expect(tokens.restaurantMarker, BrandPalette.restaurantMarker);
    });
  });
}
