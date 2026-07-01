// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'availability_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AvailabilityController)
final availabilityControllerProvider = AvailabilityControllerProvider._();

final class AvailabilityControllerProvider
    extends $AsyncNotifierProvider<AvailabilityController, bool> {
  AvailabilityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availabilityControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availabilityControllerHash();

  @$internal
  @override
  AvailabilityController create() => AvailabilityController();
}

String _$availabilityControllerHash() =>
    r'9f765aa94884fa4aa30b111aa3a9e13a760d2bee';

abstract class _$AvailabilityController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
