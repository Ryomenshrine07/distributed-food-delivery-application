package com.service.delivery.event;

import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderDeliveredEvent(

        UUID orderId,

        UUID deliveryPartnerId,

        OffsetDateTime deliveredAt

) {}