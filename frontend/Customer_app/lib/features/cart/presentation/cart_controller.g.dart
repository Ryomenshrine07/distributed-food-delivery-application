// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cartControllerHash() => r'4cf4eda65b1af4fbc59c68fcf3f787095acd45a5';

/// Controller for the shopping cart.
///
/// Kept-alive so the cart persists across screen navigations.
/// Enforces the single-restaurant invariant: adding from a different
/// restaurant clears the current cart.
///
/// Copied from [CartController].
@ProviderFor(CartController)
final cartControllerProvider = NotifierProvider<CartController, Cart>.internal(
  CartController.new,
  name: r'cartControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cartControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CartController = Notifier<Cart>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
