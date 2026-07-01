// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$myOrdersHash() => r'62ba0cec2e5e55a0e90d7ef42712eeecbe531215';

/// Fetches the list of orders for the current user.
///
/// Copied from [myOrders].
@ProviderFor(myOrders)
final myOrdersProvider = AutoDisposeFutureProvider<List<Order>>.internal(
  myOrders,
  name: r'myOrdersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myOrdersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyOrdersRef = AutoDisposeFutureProviderRef<List<Order>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
