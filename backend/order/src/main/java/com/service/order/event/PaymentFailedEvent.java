package com.service.order.event;

import java.util.UUID;

public record PaymentFailedEvent(
        UUID orderId,
        UUID customerId,
        String reason
) {}
