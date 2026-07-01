package com.service.payment.event;

import com.service.payment.dto.RestaurantLocation;

import java.math.BigDecimal;
import java.util.UUID;

public record PaymentCompletedEvent(
        UUID paymentId,
        UUID orderId,
        UUID customerId,
        UUID restaurantId,
        BigDecimal amount,
        RestaurantLocation restaurantLocation
) {}
