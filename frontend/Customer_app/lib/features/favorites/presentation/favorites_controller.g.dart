// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoritesControllerHash() =>
    r'22b124c659682a9b2765aaabd21d28829f7f718c';

/// Controller for managing favorite restaurants using SharedPreferences.
///
/// Copied from [FavoritesController].
@ProviderFor(FavoritesController)
final favoritesControllerProvider =
    AutoDisposeNotifierProvider<FavoritesController, List<Restaurant>>.internal(
      FavoritesController.new,
      name: r'favoritesControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoritesControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FavoritesController = AutoDisposeNotifier<List<Restaurant>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
