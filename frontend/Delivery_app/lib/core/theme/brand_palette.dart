import 'package:flutter/material.dart';

/// Canonical brand color constants for the Food Delivery product family.
///
/// This block is the documented single source of truth for the brand palette
/// and is replicated **identically** in both the Customer and Delivery apps
/// (`lib/core/theme/brand_palette.dart`). Because the two apps are separate
/// Flutter packages with no shared package, consistency is enforced by keeping
/// these values in sync and by a drift-guard test in each app that asserts the
/// `ColorScheme` seed and key `AppTokens` values equal these constants.
///
/// Values mirror the design's color table:
///
/// | Role                | Light      | Dark       |
/// |---------------------|------------|------------|
/// | brandPrimary (seed) | `#2B9E49`  | `#2B9E49`  |
/// | brandPrimaryDark    | `#1F7A38`  | `#1F7A38`  |
/// | success             | `#2E7D32`  | `#66BB6A`  |
/// | warning             | `#E65100`  | `#FFB74D`  |
/// | error               | `#C62828`  | `#EF9A9A`  |
/// | info                | `#0277BD`  | `#4FC3F7`  |
/// | riderMarker         | `#2B9E49`  | `#2B9E49`  |
/// | customerMarker      | `#1565C0`  | `#1565C0`  |
/// | restaurantMarker    | `#E65100`  | `#E65100`  |
abstract final class BrandPalette {
  /// Brand green — the seed color for `ColorScheme.fromSeed` in both apps.
  static const Color brandPrimary = Color(0xFF2B9E49);

  /// Darker brand green for pressed states, scrims, and header gradients.
  static const Color brandPrimaryDark = Color(0xFF1F7A38);

  // Semantic roles — light.
  static const Color successLight = Color(0xFF2E7D32);
  static const Color warningLight = Color(0xFFE65100);
  static const Color errorLight = Color(0xFFC62828);
  static const Color infoLight = Color(0xFF0277BD);

  // Semantic roles — dark.
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color errorDark = Color(0xFFEF9A9A);
  static const Color infoDark = Color(0xFF4FC3F7);

  /// Rider/scooter puck fill (brand green). Identical in light and dark.
  static const Color riderMarker = Color(0xFF2B9E49);

  /// Customer/home pin (blue). Identical in light and dark.
  static const Color customerMarker = Color(0xFF1565C0);

  /// Restaurant pin (orange). Identical in light and dark.
  static const Color restaurantMarker = Color(0xFFE65100);
}
