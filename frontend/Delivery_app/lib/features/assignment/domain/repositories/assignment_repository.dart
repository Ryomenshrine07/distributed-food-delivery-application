import '../../../../core/error/result.dart';
import '../entities/delivery_assignment.dart';

abstract class AssignmentRepository {
  /// Get the cached active assignment (no backend GET — Gap 3).
  Future<DeliveryAssignment?> getActiveAssignment();

  /// Cache an assignment locally (from FCM push).
  Future<void> cacheAssignment(DeliveryAssignment assignment);

  /// Confirm pickup: POST /api/delivery/assignments/{orderId}/picked-up
  /// On NoConnectionFailure, enqueues to offline queue and returns Right(QueuedResult).
  Future<Result<void>> markPickedUp(String orderId);

  /// Clear the cached active assignment.
  Future<void> clearActiveAssignment();

  /// Get pending delivery offers
  Future<Result<List<DeliveryAssignment>>> getOffers();

  /// Accept a delivery offer
  Future<Result<void>> acceptOffer(String orderId);
}
