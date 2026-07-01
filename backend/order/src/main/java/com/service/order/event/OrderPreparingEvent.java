package com.service.order.event;

import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderPreparingEvent(

        UUID orderId,

        UUID restaurantId,

        OffsetDateTime startedAt

) {}
