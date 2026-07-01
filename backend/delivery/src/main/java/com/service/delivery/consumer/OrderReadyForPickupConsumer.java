package com.service.delivery.consumer;

import com.service.delivery.event.OrderReadyForPickupEvent;
import com.service.delivery.service.DeliveryAssignmentService;
import com.service.delivery.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class OrderReadyForPickupConsumer {

    private final DeliveryAssignmentService deliveryAssignmentService;

    @KafkaListener(
            topics = KafkaTopics.ORDER_READY_FOR_PICKUP,
            groupId = "delivery-group",
            containerFactory = "orderReadyForPickupFactory"
    )
    public void consume(OrderReadyForPickupEvent event) {
        log.info("Received OrderReadyForPickupEvent for order {}", event.orderId());
        deliveryAssignmentService.markReadyForPickup(event);
    }
}
