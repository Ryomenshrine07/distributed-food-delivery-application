package com.service.payment.producer;


import com.service.payment.constants.KafkaTopics;
import com.service.payment.event.PaymentCompletedEvent;
import com.service.payment.event.PaymentFailedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentEventProducer {

    private final KafkaTemplate<String, Object> kafkaTemplate;

    public void publishPaymentSuccessEvent(PaymentCompletedEvent event){

        kafkaTemplate.send(
                KafkaTopics.PAYMENT_COMPLETED,
                event.paymentId().toString(),
                event
        );
        log.info(
                "Published payment-success event for payment: {}",
                event.paymentId()
        );
    }

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
