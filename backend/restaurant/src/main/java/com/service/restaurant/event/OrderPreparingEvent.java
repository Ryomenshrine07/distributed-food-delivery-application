package com.service.restaurant.event;

import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderPreparingEvent(

        UUID orderId,

        UUID restaurantId,

        OffsetDateTime startedAt

) {}
