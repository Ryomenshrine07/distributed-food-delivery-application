package com.service.order.consumer;


import com.service.order.entity.Order;
import com.service.order.enums.OrderStatus;
import com.service.order.event.PaymentCompletedEvent;
import com.service.order.repository.OrderRepository;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.DltHandler;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@Slf4j
@RequiredArgsConstructor
public class PaymentCompletedConsumer {

    private final OrderRepository orderRepository;

    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;

    @KafkaListener(
            topics = "payment-completed",
            groupId = "order-group"
    )
    public void consume(String payload){
        try {
            PaymentCompletedEvent event = objectMapper.readValue(payload, PaymentCompletedEvent.class);

        Order order = orderRepository.findById(event.orderId())
                .orElseThrow();

        log.info(
                "Payment event received for order: {}",
                event.orderId()
        );
        order.setStatus(OrderStatus.CONFIRMED);
        orderRepository.save(order);
        } catch (Exception e) {
            log.error("Failed to parse payment completed event", e);
        }
    }
}
