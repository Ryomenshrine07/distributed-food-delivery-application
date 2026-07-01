import 'package:flutter/foundation.dart';

/// Domain entity for a delivery location (coordinates + address text).
///
/// Used both in order responses and the checkout flow.
@immutable
class DeliveryLocation {
  const DeliveryLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String address;
  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryLocation &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(address, latitude, longitude);

  @override
  String toString() =>
      'DeliveryLocation(address: $address, lat: $latitude, lng: $longitude)';
}
