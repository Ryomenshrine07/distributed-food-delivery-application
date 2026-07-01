// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(navigationRepository)
final navigationRepositoryProvider = NavigationRepositoryProvider._();

final class NavigationRepositoryProvider
    extends
        $FunctionalProvider<
          NavigationRepository,
          NavigationRepository,
          NavigationRepository
        >
    with $Provider<NavigationRepository> {
  NavigationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationRepositoryHash();

  @$internal
  @override
  $ProviderElement<NavigationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NavigationRepository create(Ref ref) {
    return navigationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationRepository>(value),
    );
  }
}

String _$navigationRepositoryHash() =>
    r'2d6b8d04c7d29aee7bf2a026606779bd29b5c340';

@ProviderFor(NavigationController)
final navigationControllerProvider = NavigationControllerFamily._();

final class NavigationControllerProvider
    extends $AsyncNotifierProvider<NavigationController, RouteInfo?> {
  NavigationControllerProvider._({
    required NavigationControllerFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'navigationControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$navigationControllerHash();

  @override
  String toString() {
    return r'navigationControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  NavigationController create() => NavigationController();

  @override
  bool operator ==(Object other) {
    return other is NavigationControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$navigationControllerHash() =>
    r'1c64f701b17dabaa33ed617e024b672af89868a9';

final class NavigationControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          NavigationController,
          AsyncValue<RouteInfo?>,
          RouteInfo?,
          FutureOr<RouteInfo?>,
          (String, String)
        > {
  NavigationControllerFamily._()
    : super(
        retry: null,
        name: r'navigationControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NavigationControllerProvider call(String orderId, String destination) =>
      NavigationControllerProvider._(
        argument: (orderId, destination),
        from: this,
      );

  @override
  String toString() => r'navigationControllerProvider';
}

abstract class _$NavigationController extends $AsyncNotifier<RouteInfo?> {
  late final _$args = ref.$arg as (String, String);
  String get orderId => _$args.$1;
  String get destination => _$args.$2;

  FutureOr<RouteInfo?> build(String orderId, String destination);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RouteInfo?>, RouteInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RouteInfo?>, RouteInfo?>,
              AsyncValue<RouteInfo?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
