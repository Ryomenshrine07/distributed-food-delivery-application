package com.service.delivery.event;

import java.time.OffsetDateTime;
import java.util.UUID;

public record DeliveryAssignedEvent(

        UUID orderId,

        UUID deliveryPartnerId,

        String deliveryPartnerName,

        String deliveryPartnerPhone,

        OffsetDateTime assignedAt

) {}
