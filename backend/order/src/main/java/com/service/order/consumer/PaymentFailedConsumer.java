package com.service.order.consumer;


import com.service.order.constants.KafkaTopics;
import com.service.order.entity.Order;
import com.service.order.enums.OrderStatus;
import com.service.order.event.PaymentFailedEvent;
import com.service.order.repository.OrderRepository;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class PaymentFailedConsumer {

    private final OrderRepository orderRepository;

    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    @KafkaListener(
            topics = KafkaTopics.PAYMENT_FAILED,
            groupId = "order-group"
    )
    public void consume(String payload){
        try {
            PaymentFailedEvent event = objectMapper.readValue(payload, PaymentFailedEvent.class);
            Order order = orderRepository.findById(event.orderId())
                    .orElseThrow();
    
            order.setStatus(OrderStatus.FAILED);
            orderRepository.save(order);
        } catch (Exception e) {
            // log error
        }
    }
}
