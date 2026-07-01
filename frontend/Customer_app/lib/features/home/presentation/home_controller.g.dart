// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$restaurantRepositoryHash() =>
    r'3cc1d3a32925d12efd8530d2047d28d8938aab10';

/// Provides the [RestaurantRepository] singleton.
///
/// Copied from [restaurantRepository].
@ProviderFor(restaurantRepository)
final restaurantRepositoryProvider =
    AutoDisposeProvider<RestaurantRepository>.internal(
      restaurantRepository,
      name: r'restaurantRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$restaurantRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RestaurantRepositoryRef = AutoDisposeProviderRef<RestaurantRepository>;
String _$homeFeedControllerHash() =>
    r'224b669d287c44fdab8607b222549088bdc75633';

/// Controller for the home discovery feed.
///
/// Manages paginated restaurant loading, filter state, and recommended
/// section. Uses infinite scroll with prefetch threshold.
///
/// Copied from [HomeFeedController].
@ProviderFor(HomeFeedController)
final homeFeedControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      HomeFeedController,
      HomeFeedState
    >.internal(
      HomeFeedController.new,
      name: r'homeFeedControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$homeFeedControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HomeFeedController = AutoDisposeAsyncNotifier<HomeFeedState>;
String _$restaurantSearchControllerHash() =>
    r'b2660d7628222e1bd1167b771644905ec5dc4f17';

/// Controller for restaurant search with debounce and supersede-cancel.
///
/// Copied from [RestaurantSearchController].
@ProviderFor(RestaurantSearchController)
final restaurantSearchControllerProvider =
    AutoDisposeNotifierProvider<
      RestaurantSearchController,
      AsyncValue<List<Restaurant>>
    >.internal(
      RestaurantSearchController.new,
      name: r'restaurantSearchControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$restaurantSearchControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RestaurantSearchController =
    AutoDisposeNotifier<AsyncValue<List<Restaurant>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
