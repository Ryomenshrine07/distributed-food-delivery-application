// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_lifecycle_handler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appLifecycleHandler)
final appLifecycleHandlerProvider = AppLifecycleHandlerProvider._();

final class AppLifecycleHandlerProvider
    extends
        $FunctionalProvider<
          AppLifecycleHandler,
          AppLifecycleHandler,
          AppLifecycleHandler
        >
    with $Provider<AppLifecycleHandler> {
  AppLifecycleHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLifecycleHandlerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLifecycleHandlerHash();

  @$internal
  @override
  $ProviderElement<AppLifecycleHandler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppLifecycleHandler create(Ref ref) {
    return appLifecycleHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLifecycleHandler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLifecycleHandler>(value),
    );
  }
}

String _$appLifecycleHandlerHash() =>
    r'61d49f401473925ae1811df816be40480c441c78';
