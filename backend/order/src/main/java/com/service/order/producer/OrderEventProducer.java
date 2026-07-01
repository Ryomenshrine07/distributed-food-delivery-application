package com.service.order.producer;


import com.service.order.constants.KafkaTopics;
import com.service.order.event.OrderCreatedEvent;
import com.service.order.event.OrderDeliveredEvent;
import com.service.order.event.OrderPreparingEvent;
import com.service.order.event.OrderReadyForPickupEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderEventProducer {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public void publishOrderCreated(OrderCreatedEvent event){

        kafkaTemplate.send(
                KafkaTopics.ORDER_CREATED,
                event.orderId().toString(),
                event
        );
        log.info(
                "Published order-created event for order: {}",
                event.orderId()
        );
    }

    public void publishOrderPreparing(OrderPreparingEvent event){

        kafkaTemplate.send(
                KafkaTopics.ORDER_PREPARING,
                event.orderId().toString(),
                event
        );
        log.info(
                "Published order-preparing event for order: {}",
                event.orderId()
        );
    }

    public void publishOrderReadyForPickup(OrderReadyForPickupEvent event){

        kafkaTemplate.send(
                KafkaTopics.ORDER_READY_FOR_PICKUP,
                event.orderId().toString(),
                event
        );
        log.info(
                "Published order-ready-for-pickup event for order: {}",
                event.orderId()
        );
    }

    public void publishOrderDelivered(OrderDeliveredEvent event){

        kafkaTemplate.send(
                KafkaTopics.ORDER_DELIVERED,
                event.orderId().toString(),
                event
        );
        log.info(
                "Published order-delivered event for order: {}",
                event.orderId()
        );
    }
}
