import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_confirmation.freezed.dart';
part 'pending_confirmation.g.dart';

enum ConfirmationType { pickedUp, delivered }

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
