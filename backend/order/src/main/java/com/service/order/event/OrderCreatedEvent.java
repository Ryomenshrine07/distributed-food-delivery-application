package com.service.order.event;

import com.service.order.dto.DeliveryLocationResponse;
import com.service.order.dto.RestaurantLocation;

import java.math.BigDecimal;
import java.util.UUID;

public record OrderCreatedEvent(

        UUID orderId,

        UUID customerId,

        UUID restaurantId,

        BigDecimal totalAmount,

        DeliveryLocationResponse deliveryLocation,

        RestaurantLocation restaurantLocation

) {
}
