package com.service.order.publisher;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.order.constants.KafkaTopics;
import com.service.order.entity.OutBoxEvent;
import com.service.order.event.OrderCreatedEvent;
import com.service.order.event.OrderDeliveredEvent;
import com.service.order.event.OrderPreparingEvent;
import com.service.order.event.OrderReadyForPickupEvent;
import com.service.order.producer.OrderEventProducer;
import com.service.order.repository.OutBoxRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class OutBoxPublisher {

    private final OutBoxRepository outBoxRepository;

    private final OrderEventProducer producer;

    private final ObjectMapper objectMapper;

    @Scheduled(fixedDelay = 5000)
    public void publishEvents(){

        List<OutBoxEvent> outBoxEvents = outBoxRepository.findByPublishedFalse();

        for(OutBoxEvent event: outBoxEvents){

            try{

                switch (event.getEventType()) {
                    case KafkaTopics.ORDER_CREATED -> {
                        OrderCreatedEvent orderCreatedEvent =
                                objectMapper.readValue(event.getPayload(), OrderCreatedEvent.class);
                        producer.publishOrderCreated(orderCreatedEvent);
                    }
                    case KafkaTopics.ORDER_PREPARING -> {
                        OrderPreparingEvent orderPreparingEvent =
                                objectMapper.readValue(event.getPayload(), OrderPreparingEvent.class);
                        producer.publishOrderPreparing(orderPreparingEvent);
                    }
                    case KafkaTopics.ORDER_READY_FOR_PICKUP -> {
                        OrderReadyForPickupEvent orderReadyForPickupEvent =
                                objectMapper.readValue(event.getPayload(), OrderReadyForPickupEvent.class);
                        producer.publishOrderReadyForPickup(orderReadyForPickupEvent);
                    }
                    case KafkaTopics.ORDER_DELIVERED -> {
                        OrderDeliveredEvent orderDeliveredEvent =
                                objectMapper.readValue(event.getPayload(), OrderDeliveredEvent.class);
                        producer.publishOrderDelivered(orderDeliveredEvent);
                    }
                    default -> {
                        log.warn(
                                "Unknown outbox event type '{}' for event {}",
                                event.getEventType(),
                                event.getId()
                        );
                        continue;
                    }
                }

                log.info("Published {} event for aggregate {}",
                        event.getEventType(), event.getAggregateId());
                event.setPublished(true);

                outBoxRepository.save(event);

                log.info(
                        "OutBox published entry updated for order: {}",
                        event.getAggregateId()
                );

            }catch (Exception ex){
                log.error(
                        "Failed publishing outbox event {}",
                        event.getId(),
                        ex
                );
            }
        }
    }
}
