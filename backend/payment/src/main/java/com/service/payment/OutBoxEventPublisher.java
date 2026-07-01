package com.service.payment;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.payment.entity.OutBoxEvent;
import com.service.payment.event.PaymentCompletedEvent;
import com.service.payment.producer.PaymentEventProducer;
import com.service.payment.repository.OutBoxEventRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class OutBoxEventPublisher {

    private final OutBoxEventRepository outBoxEventRepository;
    private final ObjectMapper objectMapper;
    private final PaymentEventProducer producer;

    @Scheduled(fixedDelay = 5000)
    public void publish(){

        List<OutBoxEvent> byPublishedFalse = outBoxEventRepository.findByPublishedFalse();
        for(OutBoxEvent event : byPublishedFalse){

            try {

                PaymentCompletedEvent paymentCompletedEvent
                        = objectMapper.readValue(event.getPayload(), PaymentCompletedEvent.class);

                producer.publishPaymentSuccessEvent(paymentCompletedEvent);
                log.info(
                        "payment-completed event fired for payment: {}",
                        paymentCompletedEvent.paymentId()
                );
                event.setPublished(true);
                outBoxEventRepository.save(event);
                log.info(
                        "OutBox event updated for payment: {}",
                        paymentCompletedEvent.paymentId()
                );
            }catch (Exception ex){
                log.error(
                        "Failed to publish outbox event for payment: {}",
                        event.getAggregateId(),
                        ex
                );
            }
        }
    }

}
