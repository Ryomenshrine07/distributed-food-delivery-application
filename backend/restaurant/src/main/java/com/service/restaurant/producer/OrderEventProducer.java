package com.service.restaurant.producer;


import com.service.restaurant.event.OrderCancelledEvent;
import com.service.restaurant.event.OrderPreparingEvent;
import com.service.restaurant.event.OrderReadyForPickupEvent;
import com.service.restaurant.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderEventProducer {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public void publishOrderPreparingEvent(OrderPreparingEvent event){

        kafkaTemplate.send(
                KafkaTopics.ORDER_PREPARING,
                event.orderId().toString(),
                event
        );
        log.info(
                "Order Preparing event published for order: {}",
                event.orderId()
        );
    }

    public void publishReadyForPickupEvent(OrderReadyForPickupEvent event){

        kafkaTemplate.send(
                KafkaTopics.ORDER_READY_FOR_PICKUP,
                event.orderId().toString(),
                event
        );
        log.info(
                "Order ready for pickup event published for order: {}",
                event.orderId()
        );
    }

    public void publishOrderCancellingEvent(OrderCancelledEvent event){

        kafkaTemplate.send(
                KafkaTopics.ORDER_CANCELLED,
                event.orderId().toString(),
                event
        );
        log.info(
                "Order cancelled event published for order: {}",
                event.orderId()
        );
    }
}
