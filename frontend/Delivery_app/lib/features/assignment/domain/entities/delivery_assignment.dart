import 'package:freezed_annotation/freezed_annotation.dart';
import 'delivery_status.dart';

part 'delivery_assignment.freezed.dart';
part 'delivery_assignment.g.dart';

@freezed
abstract class DeliveryAssignment with _$DeliveryAssignment {
  const factory DeliveryAssignment({
    required String id,
    required String orderId,
    @Default('Unknown Restaurant') String restaurantName,
    @Default('Unknown Address') String restaurantAddress,
    required double restaurantLatitude,
    required double restaurantLongitude,
    @Default('Unknown Customer') String customerName,
    @Default('Unknown Address') String customerAddress,
    @Default(0.0) double customerLatitude,
    @Default(0.0) double customerLongitude,
    String? customerPhone,
    @Default(0) int itemCount,
    required DeliveryStatus status,
    DateTime? assignedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) = _DeliveryAssignment;

  factory DeliveryAssignment.fromJson(Map<String, dynamic> json) =>
      _$DeliveryAssignmentFromJson(json);
}
