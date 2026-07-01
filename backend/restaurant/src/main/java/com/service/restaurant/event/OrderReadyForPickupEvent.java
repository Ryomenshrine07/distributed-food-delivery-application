package com.service.restaurant.event;

import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderReadyForPickupEvent(

        UUID orderId,

        UUID restaurantId,

        OffsetDateTime readyAt

) {}
