import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../entities/delivery_assignment.dart';
import '../entities/delivery_status.dart';
import '../repositories/assignment_repository.dart';

class ConfirmPickupUseCase {
  final AssignmentRepository _repository;

  ConfirmPickupUseCase(this._repository);

  Future<Result<void>> execute(String orderId) async {
    final assignment = await _repository.getActiveAssignment();
    if (assignment == null) {
      return const Left(UnknownFailure('No active assignment found'));
    }
    if (!assignment.status.canPickUp) {
      return Left(UnknownFailure(
        'Cannot pick up order in ${assignment.status.label} state',
      ));
    }
    return _repository.markPickedUp(orderId);
  }
}

class ConfirmDeliveryUseCase {
  final AssignmentRepository _repository;

  ConfirmDeliveryUseCase(this._repository);

  Future<Result<void>> execute(String orderId) async {
    final assignment = await _repository.getActiveAssignment();
    if (assignment == null) {
      return const Left(UnknownFailure('No active assignment found'));
    }
    if (!assignment.status.canDeliver) {
      return Left(UnknownFailure(
        'Cannot deliver order in ${assignment.status.label} state',
      ));
    }
    return _repository.markDelivered(orderId);
  }
}
