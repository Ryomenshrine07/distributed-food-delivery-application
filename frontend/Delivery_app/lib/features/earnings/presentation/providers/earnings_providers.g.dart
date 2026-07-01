// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EarningsController)
final earningsControllerProvider = EarningsControllerProvider._();

final class EarningsControllerProvider
    extends $AsyncNotifierProvider<EarningsController, EarningsInfo> {
  EarningsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'earningsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$earningsControllerHash();

  @$internal
  @override
  EarningsController create() => EarningsController();
}

String _$earningsControllerHash() =>
    r'13cec1c06cbfb7ae872c22549a20f2c984dc7048';

abstract class _$EarningsController extends $AsyncNotifier<EarningsInfo> {
  FutureOr<EarningsInfo> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<EarningsInfo>, EarningsInfo>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<EarningsInfo>, EarningsInfo>,
              AsyncValue<EarningsInfo>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
