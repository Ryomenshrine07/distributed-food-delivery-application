package com.service.delivery.consumer;


import com.service.delivery.event.PaymentCompletedEvent;
import com.service.delivery.service.DeliveryAssignmentService;
import com.service.delivery.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

/**
 * Thin inbound adapter: receives PaymentCompletedEvent and hands it to the assignment
 * service. It holds no business logic, no repositories and no transaction - those belong
 * to {@link DeliveryAssignmentService}.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class PaymentEventConsumer {

    private final DeliveryAssignmentService deliveryAssignmentService;

    @KafkaListener(
            topics = KafkaTopics.PAYMENT_COMPLETED,
            groupId = "delivery-group",
            containerFactory = "paymentCompletedFactory"
    )
    public void consume(PaymentCompletedEvent event) {
        log.info("Received PaymentCompletedEvent for order {}", event.orderId());
        deliveryAssignmentService.assignDeliveryForPayment(event);
    }
}
