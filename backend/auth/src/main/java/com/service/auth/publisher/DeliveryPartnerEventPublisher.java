package com.service.auth.publisher;


import com.service.auth.event.DeliveryPartnerCreatedEvent;
import com.service.auth.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class DeliveryPartnerEventPublisher {

    private final KafkaTemplate<String, DeliveryPartnerCreatedEvent> kafkaTemplate;

    public void publish(DeliveryPartnerCreatedEvent event){

        kafkaTemplate.send(
                KafkaTopics.DELIVERY_PARTNER_CREATED,
                event.deliveryPartnerId().toString(),
                event
        );

        log.info(
                "delivery-partner-created event published for: {}",
                event.deliveryPartnerId()
        );
    }
}
