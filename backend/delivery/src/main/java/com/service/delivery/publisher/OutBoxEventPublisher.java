package com.service.delivery.publisher;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.delivery.entity.OutBoxEvent;
import com.service.delivery.event.DeliveryAssignedEvent;
import com.service.delivery.event.OrderDeliveredEvent;
import com.service.delivery.event.OrderPickedUpEvent;
import com.service.delivery.producer.DeliveryEventProducer;
import com.service.delivery.producer.OrderEventProducer;
import com.service.delivery.repository.OutBoxEventRepository;
import com.service.delivery.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * Polls the outbox and publishes unsent events to Kafka, then marks them published.
 *
 * <p>This is the only component that talks to the Kafka producers. It performs no business
 * logic - it just deserializes the stored payload and forwards it.
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class OutBoxEventPublisher {

    private final OutBoxEventRepository outBoxEventRepository;

    private final ObjectMapper objectMapper;

    private final DeliveryEventProducer deliveryEventProducer;

    private final OrderEventProducer orderEventProducer;

    @Scheduled(fixedDelay = 5000)
    public void publish() {

        List<OutBoxEvent> events = outBoxEventRepository.findByPublishedFalse();

        for (OutBoxEvent event : events) {

            try {

                switch (event.getEventType()) {
                    case KafkaTopics.DELIVERY_ASSIGNED -> {
                        DeliveryAssignedEvent payload =
                                objectMapper.readValue(event.getPayload(), DeliveryAssignedEvent.class);
                        deliveryEventProducer.publishDeliveryAssignedEvent(payload);
                    }
                    case KafkaTopics.ORDER_DELIVERED -> {
                        OrderDeliveredEvent payload =
                                objectMapper.readValue(event.getPayload(), OrderDeliveredEvent.class);
                        orderEventProducer.publishOrderDeliveredEvent(payload);
                    }
                    case KafkaTopics.ORDER_PICKED_UP -> {
                        OrderPickedUpEvent payload =
                                objectMapper.readValue(event.getPayload(), OrderPickedUpEvent.class);
                        orderEventProducer.publishOrderPickUpEvent(payload);
                    }
                    default -> {
                        log.warn("Unknown outbox event type '{}' for event {}",
                                event.getEventType(), event.getId());
                        continue;
                    }
                }

                event.setPublished(true);
                outBoxEventRepository.save(event);

            } catch (Exception ex) {
                log.error("Failed to publish outbox event {}: {}", event.getId(), ex.getMessage());
            }
        }
    }
}
