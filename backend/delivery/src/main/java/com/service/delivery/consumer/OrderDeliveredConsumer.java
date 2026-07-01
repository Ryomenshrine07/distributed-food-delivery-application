package com.service.delivery.consumer;


import com.service.delivery.event.OrderDeliveredEvent;
import com.service.delivery.service.DeliveryAssignmentService;
import com.service.delivery.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

/**
 * Reacts to the customer's delivery confirmation.
 *
 * <p>The Order Service emits {@link OrderDeliveredEvent} on the {@code order-delivered} topic
 * when the owning customer confirms receipt of their order. This consumer is the delivery
 * domain's rider-release trigger: it replaces the removed rider self-completion path, moving
 * the release onto the authoritative customer confirmation.
 *
 * <p>Thin inbound adapter - it holds no business logic, repositories or transaction. It simply
 * delegates to {@link DeliveryAssignmentService#releaseForDeliveredOrder(java.util.UUID)}, which
 * frees the assigned rider idempotently (a redelivered event is a no-op). The
 * {@code order-delivered} topic contract is unchanged; only a consumer is added.
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class OrderDeliveredConsumer {

    private final DeliveryAssignmentService deliveryAssignmentService;

    @KafkaListener(
            topics = KafkaTopics.ORDER_DELIVERED,
            groupId = "delivery-group",
            containerFactory = "orderDeliveredFactory"
    )
    public void consume(OrderDeliveredEvent event) {
        log.info("Received OrderDeliveredEvent for order {}", event.orderId());
        deliveryAssignmentService.releaseForDeliveredOrder(event.orderId());
    }
}
