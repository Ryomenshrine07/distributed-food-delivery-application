package com.service.order.producer;

import com.service.order.constants.KafkaTopics;
import com.service.order.event.PaymentFailedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;


@Component
@Slf4j
@RequiredArgsConstructor
public class PaymentEventProducer {
    private KafkaTemplate<String, Object> kafkaTemplate;

    public void publishPaymentFailedEvent(PaymentFailedEvent event){

        kafkaTemplate.send(
                KafkaTopics.PAYMENT_FAILED,
                event.orderId().toString(),
                event
        );

        log.info(
                "Published payment-failed event for order: {}",
                event.orderId().toString()
        );
    }
}
