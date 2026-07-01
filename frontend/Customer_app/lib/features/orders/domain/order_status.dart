/// The lifecycle states an order can occupy.
///
/// These mirror the backend `OrderStatus` enum (order service) one-to-one for
/// the nine real states, plus a tolerant [unknown] sentinel that decoding
/// routes any unrecognized wire value to. The sentinel guarantees that adding a
/// new backend status can never crash decoding; it is deliberately kept out of
/// the Active/Previous partition logic (see order status logic, task 16).
enum OrderStatus {
  /// Order created, awaiting payment confirmation.
  pendingPayment,

  /// Payment confirmed; order accepted.
  confirmed,

  /// Restaurant is preparing the order.
  preparing,

  /// Order is ready to be picked up by a delivery partner.
  readyForPickup,

  /// A delivery partner has been assigned to the order.
  deliveryPartnerAssigned,

  /// Order is on its way to the customer.
  outForDelivery,

  /// Order has been delivered (terminal).
  delivered,

  /// Order was cancelled (terminal).
  cancelled,

  /// Order failed, e.g. payment failure (terminal).
  failed,

  /// Safe sentinel for any status not recognized by this client.
  ///
  /// Never produced by the backend; only the result of decoding an
  /// unrecognized value. Excluded from partition/lifecycle logic.
  unknown,
}
