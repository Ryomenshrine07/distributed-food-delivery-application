package com.service.order.event;

import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderDeliveredEvent(

        UUID orderId,

        UUID deliveryPartnerId,

        OffsetDateTime deliveredAt

) {}
