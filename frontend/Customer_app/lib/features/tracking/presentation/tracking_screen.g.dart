// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deliveryPartnerDetailsHash() =>
    r'1f83c6dd87d1dc49bdc1159f2341fc7d8c158ffa';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [deliveryPartnerDetails].
@ProviderFor(deliveryPartnerDetails)
const deliveryPartnerDetailsProvider = DeliveryPartnerDetailsFamily();

/// See also [deliveryPartnerDetails].
class DeliveryPartnerDetailsFamily
    extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [deliveryPartnerDetails].
  const DeliveryPartnerDetailsFamily();

  /// See also [deliveryPartnerDetails].
  DeliveryPartnerDetailsProvider call(String? partnerId) {
    return DeliveryPartnerDetailsProvider(partnerId);
  }

  @override
  DeliveryPartnerDetailsProvider getProviderOverride(
    covariant DeliveryPartnerDetailsProvider provider,
  ) {
    return call(provider.partnerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deliveryPartnerDetailsProvider';
}

/// See also [deliveryPartnerDetails].
class DeliveryPartnerDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// See also [deliveryPartnerDetails].
  DeliveryPartnerDetailsProvider(String? partnerId)
    : this._internal(
        (ref) =>
            deliveryPartnerDetails(ref as DeliveryPartnerDetailsRef, partnerId),
        from: deliveryPartnerDetailsProvider,
        name: r'deliveryPartnerDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$deliveryPartnerDetailsHash,
        dependencies: DeliveryPartnerDetailsFamily._dependencies,
        allTransitiveDependencies:
            DeliveryPartnerDetailsFamily._allTransitiveDependencies,
        partnerId: partnerId,
      );

  DeliveryPartnerDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.partnerId,
  }) : super.internal();

  final String? partnerId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>?> Function(DeliveryPartnerDetailsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeliveryPartnerDetailsProvider._internal(
        (ref) => create(ref as DeliveryPartnerDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        partnerId: partnerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _DeliveryPartnerDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeliveryPartnerDetailsProvider &&
        other.partnerId == partnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeliveryPartnerDetailsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `partnerId` of this provider.
  String? get partnerId;
}

class _DeliveryPartnerDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with DeliveryPartnerDetailsRef {
  _DeliveryPartnerDetailsProviderElement(super.provider);

  @override
  String? get partnerId => (origin as DeliveryPartnerDetailsProvider).partnerId;
}

String _$restaurantDetailsHash() => r'9a9319abdd08da224a15cc6840be0056e2d21bb7';

/// See also [restaurantDetails].
@ProviderFor(restaurantDetails)
const restaurantDetailsProvider = RestaurantDetailsFamily();

/// See also [restaurantDetails].
class RestaurantDetailsFamily
    extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// See also [restaurantDetails].
  const RestaurantDetailsFamily();

  /// See also [restaurantDetails].
  RestaurantDetailsProvider call(String restaurantId) {
    return RestaurantDetailsProvider(restaurantId);
  }

  @override
  RestaurantDetailsProvider getProviderOverride(
    covariant RestaurantDetailsProvider provider,
  ) {
    return call(provider.restaurantId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'restaurantDetailsProvider';
}

/// See also [restaurantDetails].
class RestaurantDetailsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// See also [restaurantDetails].
  RestaurantDetailsProvider(String restaurantId)
    : this._internal(
        (ref) => restaurantDetails(ref as RestaurantDetailsRef, restaurantId),
        from: restaurantDetailsProvider,
        name: r'restaurantDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$restaurantDetailsHash,
        dependencies: RestaurantDetailsFamily._dependencies,
        allTransitiveDependencies:
            RestaurantDetailsFamily._allTransitiveDependencies,
        restaurantId: restaurantId,
      );

  RestaurantDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.restaurantId,
  }) : super.internal();

  final String restaurantId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>?> Function(RestaurantDetailsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RestaurantDetailsProvider._internal(
        (ref) => create(ref as RestaurantDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        restaurantId: restaurantId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _RestaurantDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RestaurantDetailsProvider &&
        other.restaurantId == restaurantId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, restaurantId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RestaurantDetailsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `restaurantId` of this provider.
  String get restaurantId;
}

class _RestaurantDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with RestaurantDetailsRef {
  _RestaurantDetailsProviderElement(super.provider);

  @override
  String get restaurantId => (origin as RestaurantDetailsProvider).restaurantId;
}

String _$orderTrackingControllerHash() =>
    r'79efaf5f7c91d0d86e170c408feacdc0035b4603';

abstract class _$OrderTrackingController
    extends BuildlessAutoDisposeAsyncNotifier<Order> {
  late final String orderId;

  FutureOr<Order> build(String orderId);
}

/// See also [OrderTrackingController].
@ProviderFor(OrderTrackingController)
const orderTrackingControllerProvider = OrderTrackingControllerFamily();

/// See also [OrderTrackingController].
class OrderTrackingControllerFamily extends Family<AsyncValue<Order>> {
  /// See also [OrderTrackingController].
  const OrderTrackingControllerFamily();

  /// See also [OrderTrackingController].
  OrderTrackingControllerProvider call(String orderId) {
    return OrderTrackingControllerProvider(orderId);
  }

  @override
  OrderTrackingControllerProvider getProviderOverride(
    covariant OrderTrackingControllerProvider provider,
  ) {
    return call(provider.orderId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'orderTrackingControllerProvider';
}

/// See also [OrderTrackingController].
class OrderTrackingControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<OrderTrackingController, Order> {
  /// See also [OrderTrackingController].
  OrderTrackingControllerProvider(String orderId)
    : this._internal(
        () => OrderTrackingController()..orderId = orderId,
        from: orderTrackingControllerProvider,
        name: r'orderTrackingControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$orderTrackingControllerHash,
        dependencies: OrderTrackingControllerFamily._dependencies,
        allTransitiveDependencies:
            OrderTrackingControllerFamily._allTransitiveDependencies,
        orderId: orderId,
      );

  OrderTrackingControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.orderId,
  }) : super.internal();

  final String orderId;

  @override
  FutureOr<Order> runNotifierBuild(covariant OrderTrackingController notifier) {
    return notifier.build(orderId);
  }

  @override
  Override overrideWith(OrderTrackingController Function() create) {
    return ProviderOverride(
      origin: this,
      override: OrderTrackingControllerProvider._internal(
        () => create()..orderId = orderId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        orderId: orderId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<OrderTrackingController, Order>
  createElement() {
    return _OrderTrackingControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderTrackingControllerProvider && other.orderId == orderId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, orderId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OrderTrackingControllerRef on AutoDisposeAsyncNotifierProviderRef<Order> {
  /// The parameter `orderId` of this provider.
  String get orderId;
}

class _OrderTrackingControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<OrderTrackingController, Order>
    with OrderTrackingControllerRef {
  _OrderTrackingControllerProviderElement(super.provider);

  @override
  String get orderId => (origin as OrderTrackingControllerProvider).orderId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
