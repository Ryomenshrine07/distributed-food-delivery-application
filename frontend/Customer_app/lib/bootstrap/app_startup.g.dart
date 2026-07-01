// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_startup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appStartupHash() => r'f1c4889e210ea2ed244f31027bbeee597bd3a664';

/// Bootstrap provider that determines the app's initial auth state.
///
/// Reads the persisted session from secure storage:
/// - If a valid (non-expired) token exists → returns the [Session].
/// - If no token or expired → returns `null`.
///
/// The router's redirect guard uses this to route to `/home` or `/login`.
///
/// Copied from [appStartup].
@ProviderFor(appStartup)
final appStartupProvider = FutureProvider<Session?>.internal(
  appStartup,
  name: r'appStartupProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appStartupHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppStartupRef = FutureProviderRef<Session?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
