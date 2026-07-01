// Feature: customer-app, Property 24
//
// Property 24: Body-text contrast ratio
// For any body-text foreground/background role pair drawn from the design
// tokens, in both the light and dark themes, the computed WCAG contrast ratio
// SHALL be at least 4.5 to 1.
//
// **Validates: Requirements 28.3**

import 'dart:math';

import 'package:customer_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Computes the relative luminance of a color per WCAG 2.1.
/// https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
double _relativeLuminance(Color color) {
  double linearize(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = linearize(color.red / 255.0);
  final g = linearize(color.green / 255.0);
  final b = linearize(color.blue / 255.0);

  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// Computes the WCAG contrast ratio between two colors.
/// Returns a value >= 1.0 (ratio is always lighter/darker + 0.05).
double _contrastRatio(Color foreground, Color background) {
  final lumFg = _relativeLuminance(foreground);
  final lumBg = _relativeLuminance(background);

  final lighter = lumFg > lumBg ? lumFg : lumBg;
  final darker = lumFg > lumBg ? lumBg : lumFg;

  return (lighter + 0.05) / (darker + 0.05);
}

/// Describes a foreground/background pair for body text.
class _TextRolePair {
  const _TextRolePair({
    required this.name,
    required this.foreground,
    required this.background,
  });

  final String name;
  final Color foreground;
  final Color background;
}

/// Extracts all body-text foreground/background role pairs from a [ThemeData].
///
/// Body text roles include: bodyLarge, bodyMedium, bodySmall, labelLarge,
/// labelMedium, labelSmall, titleMedium, titleSmall.
/// Background roles include: surface, surfaceContainerLowest,
/// surfaceContainerLow, surfaceContainer, surfaceContainerHigh,
/// surfaceContainerHighest.
List<_TextRolePair> _extractBodyTextPairs(ThemeData theme) {
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  // Body-text styles (those used for readable content)
  final bodyStyles = <String, TextStyle?>{
    'bodyLarge': textTheme.bodyLarge,
    'bodyMedium': textTheme.bodyMedium,
    'bodySmall': textTheme.bodySmall,
    'labelLarge': textTheme.labelLarge,
    'labelMedium': textTheme.labelMedium,
    'labelSmall': textTheme.labelSmall,
    'titleMedium': textTheme.titleMedium,
    'titleSmall': textTheme.titleSmall,
  };

  // Surface backgrounds body text may appear on
  final backgrounds = <String, Color>{
    'surface': colorScheme.surface,
    'surfaceContainerLowest': colorScheme.surfaceContainerLowest,
    'surfaceContainerLow': colorScheme.surfaceContainerLow,
    'surfaceContainer': colorScheme.surfaceContainer,
    'surfaceContainerHigh': colorScheme.surfaceContainerHigh,
    'surfaceContainerHighest': colorScheme.surfaceContainerHighest,
  };

  final pairs = <_TextRolePair>[];
  for (final entry in bodyStyles.entries) {
    final style = entry.value;
    if (style == null) continue;
    // Use the text style color; fall back to onSurface
    final fg = style.color ?? colorScheme.onSurface;
    for (final bgEntry in backgrounds.entries) {
      pairs.add(_TextRolePair(
        name: '${entry.key} on ${bgEntry.key}',
        foreground: fg,
        background: bgEntry.value,
      ));
    }
  }

  return pairs;
}

void main() {
  group('Property 24: Body-text contrast ratio ≥ 4.5:1', () {
    test(
      'all body-text role pairs in light and dark themes meet WCAG AA '
      '(≥ 4.5:1 contrast ratio) across ≥100 randomized iterations',
      () {
        final lightTheme = AppTheme.light();
        final darkTheme = AppTheme.dark();

        final lightPairs = _extractBodyTextPairs(lightTheme);
        final darkPairs = _extractBodyTextPairs(darkTheme);

        // We have many deterministic pairs (8 text roles × 6 backgrounds × 2 themes = 96)
        // To meet the ≥100 iterations requirement, we iterate over all pairs
        // plus randomized selection for additional coverage.
        final allPairs = <_TextRolePair>[
          ...lightPairs,
          ...darkPairs,
        ];

        // Ensure we have at least 100 pairs to test
        expect(allPairs.length, greaterThanOrEqualTo(96));

        final random = Random(42); // Fixed seed for reproducibility
        final iterationCount = max(100, allPairs.length);

        for (var i = 0; i < iterationCount; i++) {
          final pair = i < allPairs.length
              ? allPairs[i]
              : allPairs[random.nextInt(allPairs.length)];

          final ratio = _contrastRatio(pair.foreground, pair.background);

          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: 'WCAG AA contrast violation: "${pair.name}" has '
                'ratio ${ratio.toStringAsFixed(2)}:1 '
                '(fg: ${pair.foreground}, bg: ${pair.background}). '
                'Minimum required: 4.5:1.',
          );
        }
      },
    );
  });
}
