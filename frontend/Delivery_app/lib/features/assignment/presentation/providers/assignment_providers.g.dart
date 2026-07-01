// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assignmentRepository)
final assignmentRepositoryProvider = AssignmentRepositoryProvider._();

final class AssignmentRepositoryProvider
    extends
        $FunctionalProvider<
          AssignmentRepository,
          AssignmentRepository,
          AssignmentRepository
        >
    with $Provider<AssignmentRepository> {
  AssignmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignmentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<AssignmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AssignmentRepository create(Ref ref) {
    return assignmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssignmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssignmentRepository>(value),
    );
  }
}

String _$assignmentRepositoryHash() =>
    r'4c0102f019879de830ab3023bf3cec5307fbd892';

@ProviderFor(confirmPickupUseCase)
final confirmPickupUseCaseProvider = ConfirmPickupUseCaseProvider._();

final class ConfirmPickupUseCaseProvider
    extends
        $FunctionalProvider<
          ConfirmPickupUseCase,
          ConfirmPickupUseCase,
          ConfirmPickupUseCase
        >
    with $Provider<ConfirmPickupUseCase> {
  ConfirmPickupUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'confirmPickupUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$confirmPickupUseCaseHash();

  @$internal
  @override
  $ProviderElement<ConfirmPickupUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConfirmPickupUseCase create(Ref ref) {
    return confirmPickupUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConfirmPickupUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConfirmPickupUseCase>(value),
    );
  }
}

String _$confirmPickupUseCaseHash() =>
    r'ec3811e962a493e7c42db5b9687dc67ce3be9f46';

@ProviderFor(AssignmentController)
final assignmentControllerProvider = AssignmentControllerProvider._();

final class AssignmentControllerProvider
    extends $AsyncNotifierProvider<AssignmentController, DeliveryAssignment?> {
  AssignmentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assignmentControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assignmentControllerHash();

  @$internal
  @override
  AssignmentController create() => AssignmentController();
}

String _$assignmentControllerHash() =>
    r'ed3b0a19408e7bcce1f25b9a63ebb20a99b50fd4';

abstract class _$AssignmentController
    extends $AsyncNotifier<DeliveryAssignment?> {
  FutureOr<DeliveryAssignment?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<DeliveryAssignment?>, DeliveryAssignment?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DeliveryAssignment?>, DeliveryAssignment?>,
              AsyncValue<DeliveryAssignment?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
