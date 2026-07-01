package com.service.order.consumer;


import com.service.order.constants.KafkaTopics;
import com.service.order.enums.OrderStatus;
import com.service.order.event.OrderDeliveredEvent;
import com.service.order.repository.OrderRepository;
import com.service.order.service.OrderStatusUpdateService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderDeliveredConsumer {

    private final OrderStatusUpdateService orderStatusUpdateService;

    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    @KafkaListener(
            topics = KafkaTopics.ORDER_DELIVERED,
            groupId = "order-group"
    )
    public void consume(String payload){
        try {
            OrderDeliveredEvent event = objectMapper.readValue(payload, OrderDeliveredEvent.class);
            orderStatusUpdateService.updateStatus(event.orderId(), OrderStatus.DELIVERED);
            log.info(
                    "Order {} status updated to Delivered",
                    event.orderId()
            );
        } catch (Exception e) {
            log.error("Failed to parse order delivered event", e);
        }
    }
}
