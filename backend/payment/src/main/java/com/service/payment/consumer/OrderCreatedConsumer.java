package com.service.payment.consumer;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.payment.constants.KafkaTopics;
import com.service.payment.dto.RestaurantLocation;
import com.service.payment.entity.OutBoxEvent;
import com.service.payment.entity.Payment;
import com.service.payment.enums.PaymentStatus;
import com.service.payment.event.OrderCreatedEvent;
import com.service.payment.event.PaymentCompletedEvent;
import com.service.payment.event.PaymentFailedEvent;
import com.service.payment.exception.PaymentProcessingException;
import com.service.payment.producer.PaymentEventProducer;
import com.service.payment.repository.OutBoxEventRepository;
import com.service.payment.repository.PaymentRepository;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.kafka.annotation.DltHandler;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.annotation.RetryableTopic;
import org.springframework.retry.annotation.Backoff;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.OffsetDateTime;


@Component
@AllArgsConstructor
@Slf4j
public class OrderCreatedConsumer {

    private final PaymentRepository paymentRepository;
    private final PaymentEventProducer paymentEventProducer;
    private final ObjectMapper objectMapper;
    private final OutBoxEventRepository outBoxEventRepository;

    @RetryableTopic(
            attempts = "3",
            backoff = @Backoff(
                    delay = 5_000,
                    multiplier = 2.0
            ),
            dltTopicSuffix = "-dlt"
    )
    @KafkaListener(
            topics = KafkaTopics.ORDER_CREATED,
            groupId = "payment-group"
    )
    public void consume(OrderCreatedEvent event){

        log.info(
                "Consumer: {} , order-created event for {}",
                Thread.currentThread().getName(),
                event.orderId()
                );

        if(paymentRepository.existsByOrderId(event.orderId())){
            log.info("Payment already exits {}", event.orderId());
            return;
        }

        Payment payment = Payment.builder()
                .orderId(event.orderId())
                .customerId(event.customerId())
                .amount(event.totalAmount())
                .restaurantId(event.restaurantId())
                .status(PaymentStatus.PENDING)
                .build();

        try{
            Payment p = paymentRepository.save(payment);
            log.info("Payment created for order: {}", event.orderId());

            try {
                OutBoxEvent outBoxEvent = OutBoxEvent.builder()
                        .aggregateId(p.getId())
                        .aggregateType("PAYMENT")
                        .eventType("payment-completed")
                        .payload(
                                objectMapper.writeValueAsString(
                                        new PaymentCompletedEvent(
                                                p.getId(),
                                                p.getOrderId(),
                                                p.getCustomerId(),
                                                p.getRestaurantId(),
                                                p.getAmount(),
                                                new RestaurantLocation(
                                                        event.restaurantLocation().latitude(),
                                                        event.restaurantLocation().longitude()
                                                )
                                        )
                                )
                        )
                        .createdAt(OffsetDateTime.now())
                        .published(false)
                        .build();
                outBoxEventRepository.save(outBoxEvent);
                log.info(
                        "Outbox event saved for payment: {}",
                        p.getId()
                );
            }catch (JsonProcessingException ex){
                log.error(
                        "Failed to send payment event for payment: {}",
                        p.getId(),
                        ex
                );
            }

        }catch (DataIntegrityViolationException ex){
            log.info("Payment already processed for order : {}", event.orderId());
            return;
        }
    }

    @DltHandler
    public void handleDlt(OrderCreatedEvent event){
        log.error(
                "Order {} moved to DLT",
                event.orderId()
        );

        paymentEventProducer.publishPaymentFailedEvent(
                new PaymentFailedEvent(
                        event.orderId(),
                        event.customerId(),
                        "Payment Gateway unavailable"
                )
        );
    }
}
