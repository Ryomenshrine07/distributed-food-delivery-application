// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addresses_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$addressesControllerHash() =>
    r'4a26e52703822138cad06fcf6539987fdae8ebb8';

/// Controller for managing saved addresses using SharedPreferences.
///
/// Copied from [AddressesController].
@ProviderFor(AddressesController)
final addressesControllerProvider =
    AutoDisposeNotifierProvider<
      AddressesController,
      List<SavedAddress>
    >.internal(
      AddressesController.new,
      name: r'addressesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$addressesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AddressesController = AutoDisposeNotifier<List<SavedAddress>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
