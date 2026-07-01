import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/preferences.dart';

part 'addresses_controller.g.dart';

@immutable
class SavedAddress {
  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
        id: json['id'] as String,
        label: json['label'] as String,
        address: json['address'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
      );
}

const _kAddressesKey = 'customer_saved_addresses';

/// Controller for managing saved addresses using SharedPreferences.
@riverpod
class AddressesController extends _$AddressesController {
  @override
  List<SavedAddress> build() {
    return _loadAddresses();
  }

  List<SavedAddress> _loadAddresses() {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_kAddressesKey);
    if (jsonStr == null) return [];
    
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => SavedAddress.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAddress(SavedAddress address) async {
    final updated = [...state, address];
    await _persist(updated);
  }

  Future<void> removeAddress(String id) async {
    final updated = state.where((a) => a.id != id).toList();
    await _persist(updated);
  }

  Future<void> _persist(List<SavedAddress> addresses) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonList = addresses.map((a) => a.toJson()).toList();
    await prefs.setString(_kAddressesKey, jsonEncode(jsonList));
    state = addresses;
  }
}
