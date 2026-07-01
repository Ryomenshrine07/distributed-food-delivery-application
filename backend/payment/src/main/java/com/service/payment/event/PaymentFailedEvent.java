package com.service.payment.event;

import java.util.UUID;

public record PaymentFailedEvent(
        UUID orderId,
        UUID customerId,
        String reason
) {}
