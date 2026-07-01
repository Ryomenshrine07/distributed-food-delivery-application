package com.service.order.event;

import java.time.OffsetDateTime;
import java.util.UUID;

public record OrderPickedUpEvent(

        UUID orderId,

        UUID deliveryPartnerId,

        OffsetDateTime pickedUpAt

) {}
