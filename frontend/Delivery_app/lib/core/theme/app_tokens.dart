import 'package:flutter/material.dart';

import 'brand_palette.dart';

class AppTokens extends ThemeExtension<AppTokens> {
  final Color primary;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // Map-marker color tokens
  final Color riderMarker;
  final Color customerMarker;
  final Color restaurantMarker;

  final Map<String, Color> deliveryStatusColors;

  // 4-pt spacing scale
  final double space4;
  final double space8;
  final double space12;
  final double space16;
  final double space24;
  final double space32;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;

  final double elevationSm;
  final double elevationMd;
  final double elevationLg;

  const AppTokens({
    required this.primary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.riderMarker,
    required this.customerMarker,
    required this.restaurantMarker,
    required this.deliveryStatusColors,
    this.space4 = 4.0,
    this.space8 = 8.0,
    this.space12 = 12.0,
    this.space16 = 16.0,
    this.space24 = 24.0,
    this.space32 = 32.0,
    this.radiusSm = 4.0,
    this.radiusMd = 8.0,
    this.radiusLg = 16.0,
    this.elevationSm = 2.0,
    this.elevationMd = 4.0,
    this.elevationLg = 8.0,
  });

  factory AppTokens.light() {
    return const AppTokens(
      primary: BrandPalette.brandPrimary,
      success: BrandPalette.successLight,
      warning: BrandPalette.warningLight,
      error: BrandPalette.errorLight,
      info: BrandPalette.infoLight,
      riderMarker: BrandPalette.riderMarker,
      customerMarker: BrandPalette.customerMarker,
      restaurantMarker: BrandPalette.restaurantMarker,
      deliveryStatusColors: {
        'assigned': BrandPalette.customerMarker,
        'pickedUp': BrandPalette.warningLight,
        'delivered': BrandPalette.successLight,
      },
    );
  }

  factory AppTokens.dark() {
    return const AppTokens(
      primary: BrandPalette.brandPrimary,
      success: BrandPalette.successDark,
      warning: BrandPalette.warningDark,
      error: BrandPalette.errorDark,
      info: BrandPalette.infoDark,
      riderMarker: BrandPalette.riderMarker,
      customerMarker: BrandPalette.customerMarker,
      restaurantMarker: BrandPalette.restaurantMarker,
      deliveryStatusColors: {
        'assigned': BrandPalette.infoDark,
        'pickedUp': BrandPalette.warningDark,
        'delivered': BrandPalette.successDark,
      },
    );
  }

  @override
  AppTokens copyWith({
    Color? primary,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? riderMarker,
    Color? customerMarker,
    Color? restaurantMarker,
    Map<String, Color>? deliveryStatusColors,
  }) {
    return AppTokens(
      primary: primary ?? this.primary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      riderMarker: riderMarker ?? this.riderMarker,
      customerMarker: customerMarker ?? this.customerMarker,
      restaurantMarker: restaurantMarker ?? this.restaurantMarker,
      deliveryStatusColors: deliveryStatusColors ?? this.deliveryStatusColors,
      space4: space4,
      space8: space8,
      space12: space12,
      space16: space16,
      space24: space24,
      space32: space32,
      radiusSm: radiusSm,
      radiusMd: radiusMd,
      radiusLg: radiusLg,
      elevationSm: elevationSm,
      elevationMd: elevationMd,
      elevationLg: elevationLg,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) {
      return this;
    }
    return AppTokens(
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      riderMarker: Color.lerp(riderMarker, other.riderMarker, t)!,
      customerMarker: Color.lerp(customerMarker, other.customerMarker, t)!,
      restaurantMarker:
          Color.lerp(restaurantMarker, other.restaurantMarker, t)!,
      deliveryStatusColors: {
        for (final key in deliveryStatusColors.keys)
          key: Color.lerp(
                deliveryStatusColors[key],
                other.deliveryStatusColors[key],
                t,
              ) ??
              deliveryStatusColors[key]!,
      },
    );
  }
}
