// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'5c0e6d6d6a30682f240088bb1ba912ff755409ab';

/// Composition-root binding for [SharedPreferences].
///
/// Defaults to throwing because the instance must be obtained asynchronously
/// (`SharedPreferences.getInstance()`); it is overridden at the composition
/// root with the awaited instance (see `main.dart`). Tests override it after
/// `SharedPreferences.setMockInitialValues`.
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$preferencesHash() => r'ecf19046f2430840828124a4a97dee92a7780d98';

/// Provides the [Preferences] wrapper backed by [sharedPreferencesProvider].
///
/// Copied from [preferences].
@ProviderFor(preferences)
final preferencesProvider = Provider<Preferences>.internal(
  preferences,
  name: r'preferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$preferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PreferencesRef = ProviderRef<Preferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
