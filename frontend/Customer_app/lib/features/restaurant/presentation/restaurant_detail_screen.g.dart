// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_detail_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$restaurantDetailHash() => r'8464925b3dc1083dbaa66f4b9d0a53df074137d3';

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

/// Fetches a single restaurant with its menu (family provider keyed by ID).
///
/// Copied from [restaurantDetail].
@ProviderFor(restaurantDetail)
const restaurantDetailProvider = RestaurantDetailFamily();

/// Fetches a single restaurant with its menu (family provider keyed by ID).
///
/// Copied from [restaurantDetail].
class RestaurantDetailFamily extends Family<AsyncValue<Restaurant>> {
  /// Fetches a single restaurant with its menu (family provider keyed by ID).
  ///
  /// Copied from [restaurantDetail].
  const RestaurantDetailFamily();

  /// Fetches a single restaurant with its menu (family provider keyed by ID).
  ///
  /// Copied from [restaurantDetail].
  RestaurantDetailProvider call(String id) {
    return RestaurantDetailProvider(id);
  }

  @override
  RestaurantDetailProvider getProviderOverride(
    covariant RestaurantDetailProvider provider,
  ) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'restaurantDetailProvider';
}

/// Fetches a single restaurant with its menu (family provider keyed by ID).
///
/// Copied from [restaurantDetail].
class RestaurantDetailProvider extends AutoDisposeFutureProvider<Restaurant> {
  /// Fetches a single restaurant with its menu (family provider keyed by ID).
  ///
  /// Copied from [restaurantDetail].
  RestaurantDetailProvider(String id)
    : this._internal(
        (ref) => restaurantDetail(ref as RestaurantDetailRef, id),
        from: restaurantDetailProvider,
        name: r'restaurantDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$restaurantDetailHash,
        dependencies: RestaurantDetailFamily._dependencies,
        allTransitiveDependencies:
            RestaurantDetailFamily._allTransitiveDependencies,
        id: id,
      );

  RestaurantDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<Restaurant> Function(RestaurantDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RestaurantDetailProvider._internal(
        (ref) => create(ref as RestaurantDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Restaurant> createElement() {
    return _RestaurantDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RestaurantDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RestaurantDetailRef on AutoDisposeFutureProviderRef<Restaurant> {
  /// The parameter `id` of this provider.
  String get id;
}

class _RestaurantDetailProviderElement
    extends AutoDisposeFutureProviderElement<Restaurant>
    with RestaurantDetailRef {
  _RestaurantDetailProviderElement(super.provider);

  @override
  String get id => (origin as RestaurantDetailProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
