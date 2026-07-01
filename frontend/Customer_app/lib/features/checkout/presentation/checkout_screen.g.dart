// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$checkoutControllerHash() =>
    r'6efb9f7b0287f42e6ae9ad3636c0f13c87adc134';

/// Places an order via POST /orders.
///
/// Copied from [CheckoutController].
@ProviderFor(CheckoutController)
final checkoutControllerProvider =
    AutoDisposeNotifierProvider<
      CheckoutController,
      AsyncValue<Order?>
    >.internal(
      CheckoutController.new,
      name: r'checkoutControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$checkoutControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CheckoutController = AutoDisposeNotifier<AsyncValue<Order?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
