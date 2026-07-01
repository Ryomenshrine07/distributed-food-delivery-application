import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/core/theme/app_theme.dart';

void main() {
  double getContrastRatio(Color c1, Color c2) {
    final double l1 = c1.computeLuminance();
    final double l2 = c2.computeLuminance();
    return (l1 > l2) ? (l1 + 0.05) / (l2 + 0.05) : (l2 + 0.05) / (l1 + 0.05);
  }

  group('WCAG Contrast Property Test', () {
    test('Light theme body text has sufficient contrast', () {
      final theme = AppTheme.light;
      final colorScheme = theme.colorScheme;
      
      final backgroundContrast = getContrastRatio(colorScheme.onSurface, colorScheme.surface);
      final primaryContrast = getContrastRatio(colorScheme.onPrimary, colorScheme.primary);
      final errorContrast = getContrastRatio(colorScheme.onError, colorScheme.error);

      // WCAG AA requirement for body text is 4.5:1
      expect(backgroundContrast, greaterThanOrEqualTo(4.5), reason: 'onSurface contrast too low');
      expect(primaryContrast, greaterThanOrEqualTo(4.5), reason: 'onPrimary contrast too low');
      expect(errorContrast, greaterThanOrEqualTo(4.5), reason: 'onError contrast too low');
    });

    test('Dark theme body text has sufficient contrast', () {
      final theme = AppTheme.dark;
      final colorScheme = theme.colorScheme;
      
      final backgroundContrast = getContrastRatio(colorScheme.onSurface, colorScheme.surface);
      final primaryContrast = getContrastRatio(colorScheme.onPrimary, colorScheme.primary);
      final errorContrast = getContrastRatio(colorScheme.onError, colorScheme.error);

      // WCAG AA requirement for body text is 4.5:1
      expect(backgroundContrast, greaterThanOrEqualTo(4.5), reason: 'onSurface contrast too low');
      expect(primaryContrast, greaterThanOrEqualTo(4.5), reason: 'onPrimary contrast too low');
      expect(errorContrast, greaterThanOrEqualTo(4.5), reason: 'onError contrast too low');
    });
  });
}
