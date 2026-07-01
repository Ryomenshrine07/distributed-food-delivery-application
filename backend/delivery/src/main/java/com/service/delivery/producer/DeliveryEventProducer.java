package com.service.delivery.producer;


import com.service.delivery.event.DeliveryAssignedEvent;
import com.service.delivery.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class DeliveryEventProducer {

    private final KafkaTemplate<String, Object> kafkaTemplate;
    public void publishDeliveryAssignedEvent(DeliveryAssignedEvent event){

        kafkaTemplate.send(
                KafkaTopics.DELIVERY_ASSIGNED,
                event.deliveryPartnerId().toString(),
                event
        );

        log.info(
                "Published delivery event for: {}",
                event.deliveryPartnerId()
        );
    }
}
