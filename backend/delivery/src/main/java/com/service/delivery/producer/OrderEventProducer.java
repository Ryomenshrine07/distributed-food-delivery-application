package com.service.delivery.producer;


import com.service.delivery.event.OrderDeliveredEvent;
import com.service.delivery.event.OrderPickedUpEvent;
import com.service.delivery.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class OrderEventProducer {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public void publishOrderPickUpEvent(OrderPickedUpEvent event){

        kafkaTemplate.send(
                KafkaTopics.ORDER_PICKED_UP,
                event.orderId().toString(),
                event
        );

        log.info(
                "Order pick up event fired for: {}",
                event.orderId()
        );
    }

    public void publishOrderDeliveredEvent(OrderDeliveredEvent event){

        kafkaTemplate.send(
                KafkaTopics.ORDER_DELIVERED,
                event.orderId().toString(),
                event
        );

        log.info(
                "Order delivered event published for: {}",
                event.orderId()
        );
    }
}
