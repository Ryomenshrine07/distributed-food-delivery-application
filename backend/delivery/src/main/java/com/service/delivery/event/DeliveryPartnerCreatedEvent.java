package com.service.delivery.event;

import java.util.UUID;

public record DeliveryPartnerCreatedEvent(
        UUID deliveryPartnerId,
        String name,
        String phone
) {}
