package com.service.delivery.consumer;


import com.service.delivery.event.DeliveryPartnerCreatedEvent;
import com.service.delivery.service.DeliveryPartnerService;
import com.service.delivery.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

/**
 * Thin inbound adapter: receives the DeliveryPartnerCreatedEvent published by Auth and
 * delegates the local replica creation to {@link DeliveryPartnerService}.
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class DeliveryPartnerCreatedConsumer {

    private final DeliveryPartnerService deliveryPartnerService;

    @KafkaListener(
            topics = KafkaTopics.DELIVERY_PARTNER_CREATED,
            groupId = "delivery-group",
            containerFactory = "deliveryPartnerCreatedFactory"
    )
    public void consume(DeliveryPartnerCreatedEvent event) {
        log.info("Received DeliveryPartnerCreatedEvent for {}", event.deliveryPartnerId());
        deliveryPartnerService.syncFromAuth(event);
    }
}
