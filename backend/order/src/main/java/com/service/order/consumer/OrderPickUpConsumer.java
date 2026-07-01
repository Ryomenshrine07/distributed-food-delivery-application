package com.service.order.consumer;


import com.service.order.constants.KafkaTopics;
import com.service.order.enums.OrderStatus;
import com.service.order.event.OrderPickedUpEvent;
import com.service.order.repository.OrderRepository;
import com.service.order.service.OrderStatusUpdateService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderPickUpConsumer {

    private final OrderStatusUpdateService orderStatusUpdateService;
    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    @KafkaListener(
            topics = KafkaTopics.ORDER_PICKED_UP,
            groupId = "order-group"
    )
    public void consume(String payload){
        try {
            OrderPickedUpEvent event = objectMapper.readValue(payload, OrderPickedUpEvent.class);

            orderStatusUpdateService.updateStatus(event.orderId(), OrderStatus.OUT_FOR_DELIVERY);
            log.info(
                    "Order {} is out for delivery",
                    event.orderId()
            );
        } catch (Exception e) {
            log.error("Failed to parse order picked up event", e);
        }
    }
}
