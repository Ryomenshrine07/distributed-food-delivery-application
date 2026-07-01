import 'package:flutter/material.dart';

class AppTokens extends ThemeExtension<AppTokens> {
  final Color primary;
  final Color success;
  final Color warning;
  final Color error;

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
      primary: Color(0xFF6750A4),
      success: Color(0xFF4CAF50),
      warning: Color(0xFFFF9800),
      error: Color(0xFFB3261E),
      deliveryStatusColors: {
        'assigned': Colors.blue,
        'pickedUp': Colors.orange,
        'delivered': Colors.green,
      },
    );
  }

  factory AppTokens.dark() {
    return const AppTokens(
      primary: Color(0xFFD0BCFF),
      success: Color(0xFF81C784),
      warning: Color(0xFFFFB74D),
      error: Color(0xFFF2B8B5),
      deliveryStatusColors: {
        'assigned': Colors.blueAccent,
        'pickedUp': Colors.orangeAccent,
        'delivered': Colors.greenAccent,
      },
    );
  }

  @override
  AppTokens copyWith({
    Color? primary,
    Color? success,
    Color? warning,
    Color? error,
    Map<String, Color>? deliveryStatusColors,
  }) {
    return AppTokens(
      primary: primary ?? this.primary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
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
