import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_confirmation.freezed.dart';
part 'pending_confirmation.g.dart';

/// The kind of delivery confirmation queued for offline retry.
///
/// Only [pickedUp] exists: delivery completion is customer-driven (the backend
/// releases the rider on the customer's confirmation), so there is no rider
/// "delivered" confirmation to queue (Req 3.7).
enum ConfirmationType { pickedUp }

@freezed
abstract class PendingConfirmation with _$PendingConfirmation {
  const factory PendingConfirmation({
    required String id,
    required String orderId,
    required ConfirmationType type,
    required DateTime enqueuedAt,
    @Default(0) int retryCount,
  }) = _PendingConfirmation;

  factory PendingConfirmation.fromJson(Map<String, dynamic> json) =>
      _$PendingConfirmationFromJson(json);
}
