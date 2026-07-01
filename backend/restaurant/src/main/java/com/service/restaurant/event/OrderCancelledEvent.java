package com.service.restaurant.event;

import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderCancelledEvent(

        UUID orderId,

        UUID restaurantId,

        String reason,

        OffsetDateTime cancelledAt

) {}
