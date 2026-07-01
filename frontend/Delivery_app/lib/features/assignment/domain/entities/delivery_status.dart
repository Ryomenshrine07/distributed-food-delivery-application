import 'package:freezed_annotation/freezed_annotation.dart';

enum DeliveryStatus {
  @JsonValue('PENDING') pending,
  @JsonValue('ASSIGNED') assigned,
  @JsonValue('PICKED_UP') pickedUp,
  @JsonValue('DELIVERED') delivered,
}

extension DeliveryStatusX on DeliveryStatus {
  bool get canPickUp => this == DeliveryStatus.assigned;
  bool get canDeliver => this == DeliveryStatus.pickedUp;
  bool get isTerminal => this == DeliveryStatus.delivered;

  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.assigned:
        return 'Assigned';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.delivered:
        return 'Delivered';
    }
  }

  /// Returns the next valid status, or null if terminal.
  DeliveryStatus? get next {
    switch (this) {
      case DeliveryStatus.pending:
        return DeliveryStatus.assigned;
      case DeliveryStatus.assigned:
        return DeliveryStatus.pickedUp;
      case DeliveryStatus.pickedUp:
        return DeliveryStatus.delivered;
      case DeliveryStatus.delivered:
        return null;
    }
  }
}
