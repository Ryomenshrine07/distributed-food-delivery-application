import 'package:flutter/material.dart';

/// Centralized design tokens consumed by both light and dark themes.
///
/// Exposed to widgets via `Theme.of(context).extension<AppTokens>()`.
/// Includes semantic color roles, per-order-status palette,
/// a 4-pt spacing scale, border radius, and elevation tokens.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    // Semantic color roles
    required this.success,
    required this.warning,
    required this.info,
    required this.onSuccess,
    required this.onWarning,
    required this.onInfo,
    // Order-status palette
    required this.statusPendingPayment,
    required this.statusConfirmed,
    required this.statusPreparing,
    required this.statusReadyForPickup,
    required this.statusDeliveryPartnerAssigned,
    required this.statusOutForDelivery,
    required this.statusDelivered,
    required this.statusCancelled,
    required this.statusFailed,
    // Spacing (4-pt scale)
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    // Border radius
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusPill,
    // Elevation
    required this.elevationLevel0,
    required this.elevationLevel1,
    required this.elevationLevel2,
    required this.elevationLevel3,
  });

  // Semantic color roles
  final Color success;
  final Color warning;
  final Color info;
  final Color onSuccess;
  final Color onWarning;
  final Color onInfo;

  // Order-status palette
  final Color statusPendingPayment;
  final Color statusConfirmed;
  final Color statusPreparing;
  final Color statusReadyForPickup;
  final Color statusDeliveryPartnerAssigned;
  final Color statusOutForDelivery;
  final Color statusDelivered;
  final Color statusCancelled;
  final Color statusFailed;

  // Spacing (4-pt scale)
  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;

  // Border radius
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusPill;

  // Elevation
  final double elevationLevel0;
  final double elevationLevel1;
  final double elevationLevel2;
  final double elevationLevel3;


  /// Light theme tokens.
  static const light = AppTokens(
    // Semantic colors (light)
    success: Color(0xFF2E7D32),
    warning: Color(0xFFE65100),
    info: Color(0xFF0277BD),
    onSuccess: Color(0xFFFFFFFF),
    onWarning: Color(0xFFFFFFFF),
    onInfo: Color(0xFFFFFFFF),
    // Order-status palette (light)
    statusPendingPayment: Color(0xFFFFA726),
    statusConfirmed: Color(0xFF42A5F5),
    statusPreparing: Color(0xFFAB47BC),
    statusReadyForPickup: Color(0xFF26A69A),
    statusDeliveryPartnerAssigned: Color(0xFF5C6BC0),
    statusOutForDelivery: Color(0xFF66BB6A),
    statusDelivered: Color(0xFF2E7D32),
    statusCancelled: Color(0xFF757575),
    statusFailed: Color(0xFFC62828),
    // Spacing
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    spaceXl: 32,
    // Radius
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 16,
    radiusPill: 999,
    // Elevation
    elevationLevel0: 0,
    elevationLevel1: 1,
    elevationLevel2: 3,
    elevationLevel3: 6,
  );

  /// Dark theme tokens.
  static const dark = AppTokens(
    // Semantic colors (dark)
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFB74D),
    info: Color(0xFF4FC3F7),
    onSuccess: Color(0xFF1B1B1B),
    onWarning: Color(0xFF1B1B1B),
    onInfo: Color(0xFF1B1B1B),
    // Order-status palette (dark)
    statusPendingPayment: Color(0xFFFFCC80),
    statusConfirmed: Color(0xFF90CAF9),
    statusPreparing: Color(0xFFCE93D8),
    statusReadyForPickup: Color(0xFF80CBC4),
    statusDeliveryPartnerAssigned: Color(0xFF9FA8DA),
    statusOutForDelivery: Color(0xFFA5D6A7),
    statusDelivered: Color(0xFF66BB6A),
    statusCancelled: Color(0xFFBDBDBD),
    statusFailed: Color(0xFFEF9A9A),
    // Spacing
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 16,
    spaceLg: 24,
    spaceXl: 32,
    // Radius
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 16,
    radiusPill: 999,
    // Elevation
    elevationLevel0: 0,
    elevationLevel1: 1,
    elevationLevel2: 3,
    elevationLevel3: 6,
  );

  @override
  AppTokens copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? onSuccess,
    Color? onWarning,
    Color? onInfo,
    Color? statusPendingPayment,
    Color? statusConfirmed,
    Color? statusPreparing,
    Color? statusReadyForPickup,
    Color? statusDeliveryPartnerAssigned,
    Color? statusOutForDelivery,
    Color? statusDelivered,
    Color? statusCancelled,
    Color? statusFailed,
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusPill,
    double? elevationLevel0,
    double? elevationLevel1,
    double? elevationLevel2,
    double? elevationLevel3,
  }) {
    return AppTokens(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      onSuccess: onSuccess ?? this.onSuccess,
      onWarning: onWarning ?? this.onWarning,
      onInfo: onInfo ?? this.onInfo,
      statusPendingPayment: statusPendingPayment ?? this.statusPendingPayment,
      statusConfirmed: statusConfirmed ?? this.statusConfirmed,
      statusPreparing: statusPreparing ?? this.statusPreparing,
      statusReadyForPickup: statusReadyForPickup ?? this.statusReadyForPickup,
      statusDeliveryPartnerAssigned:
          statusDeliveryPartnerAssigned ?? this.statusDeliveryPartnerAssigned,
      statusOutForDelivery: statusOutForDelivery ?? this.statusOutForDelivery,
      statusDelivered: statusDelivered ?? this.statusDelivered,
      statusCancelled: statusCancelled ?? this.statusCancelled,
      statusFailed: statusFailed ?? this.statusFailed,
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusPill: radiusPill ?? this.radiusPill,
      elevationLevel0: elevationLevel0 ?? this.elevationLevel0,
      elevationLevel1: elevationLevel1 ?? this.elevationLevel1,
      elevationLevel2: elevationLevel2 ?? this.elevationLevel2,
      elevationLevel3: elevationLevel3 ?? this.elevationLevel3,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      statusPendingPayment:
          Color.lerp(statusPendingPayment, other.statusPendingPayment, t)!,
      statusConfirmed:
          Color.lerp(statusConfirmed, other.statusConfirmed, t)!,
      statusPreparing:
          Color.lerp(statusPreparing, other.statusPreparing, t)!,
      statusReadyForPickup:
          Color.lerp(statusReadyForPickup, other.statusReadyForPickup, t)!,
      statusDeliveryPartnerAssigned: Color.lerp(
          statusDeliveryPartnerAssigned,
          other.statusDeliveryPartnerAssigned,
          t)!,
      statusOutForDelivery:
          Color.lerp(statusOutForDelivery, other.statusOutForDelivery, t)!,
      statusDelivered:
          Color.lerp(statusDelivered, other.statusDelivered, t)!,
      statusCancelled:
          Color.lerp(statusCancelled, other.statusCancelled, t)!,
      statusFailed: Color.lerp(statusFailed, other.statusFailed, t)!,
      spaceXs: spaceXs + (other.spaceXs - spaceXs) * t,
      spaceSm: spaceSm + (other.spaceSm - spaceSm) * t,
      spaceMd: spaceMd + (other.spaceMd - spaceMd) * t,
      spaceLg: spaceLg + (other.spaceLg - spaceLg) * t,
      spaceXl: spaceXl + (other.spaceXl - spaceXl) * t,
      radiusSm: radiusSm + (other.radiusSm - radiusSm) * t,
      radiusMd: radiusMd + (other.radiusMd - radiusMd) * t,
      radiusLg: radiusLg + (other.radiusLg - radiusLg) * t,
      radiusPill: radiusPill + (other.radiusPill - radiusPill) * t,
      elevationLevel0:
          elevationLevel0 + (other.elevationLevel0 - elevationLevel0) * t,
      elevationLevel1:
          elevationLevel1 + (other.elevationLevel1 - elevationLevel1) * t,
      elevationLevel2:
          elevationLevel2 + (other.elevationLevel2 - elevationLevel2) * t,
      elevationLevel3:
          elevationLevel3 + (other.elevationLevel3 - elevationLevel3) * t,
    );
  }
}
