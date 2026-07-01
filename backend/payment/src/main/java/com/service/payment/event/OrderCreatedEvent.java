package com.service.payment.event;

import com.service.payment.dto.RestaurantLocation;

import java.math.BigDecimal;
import java.util.UUID;

public record OrderCreatedEvent(

        UUID orderId,

        UUID customerId,

        UUID restaurantId,

        BigDecimal totalAmount,

        DeliveryLocationEvent deliveryLocation,

        RestaurantLocation restaurantLocation
) {
}
