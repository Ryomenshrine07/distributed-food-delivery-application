package com.service.order.consumer;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.order.constants.KafkaTopics;
import com.service.order.entity.Order;
import com.service.order.enums.OrderStatus;
import com.service.order.event.DeliveryAssignedEvent;
import com.service.order.repository.OrderRepository;
import com.service.order.service.OrderStatusUpdateService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class DeliveryAssignedConsumer {


    private final OrderRepository orderRepository;

    private final OrderStatusUpdateService orderStatusUpdateService;

    private final ObjectMapper objectMapper;

    @KafkaListener(
            topics = KafkaTopics.DELIVERY_ASSIGNED,
            groupId = "order-group"
    )
    public void consume(String payload){
        try {
            DeliveryAssignedEvent event = objectMapper.readValue(payload, DeliveryAssignedEvent.class);

        Order order = orderRepository.findById(event.orderId())
                .orElseThrow(() -> new RuntimeException("Order not found: " + event.orderId()));
        order.setDeliveryPartnerId(event.deliveryPartnerId());
        order.setDeliveryPartnerName(event.deliveryPartnerName());
        order.setDeliveryPartnerPhone(event.deliveryPartnerPhone());
        order.setStatus(OrderStatus.DELIVERY_PARTNER_ASSIGNED);
        orderRepository.save(order);

        log.info(
                "Order {} updated to DELIVERY_PARTNER_ASSIGNED with partner {}",
                event.orderId(), event.deliveryPartnerId()
        );

        } catch (Exception e) {
            log.error("Failed to parse delivery assigned event", e);
        }
    }
}
