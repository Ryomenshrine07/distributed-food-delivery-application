package com.service.auth.publisher;


import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.auth.Entities.OutBoxEvent;
import com.service.auth.Repository.OutBoxEventRepository;
import com.service.auth.event.DeliveryPartnerCreatedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class OutBoxEventPublisher {

    private final DeliveryPartnerEventPublisher deliveryPartnerEventPublisher;

    private final ObjectMapper objectMapper;

    private final OutBoxEventRepository outBoxEventRepository;

    @Scheduled(fixedDelay = 5000)
    public void publish(){

        List<OutBoxEvent> events = outBoxEventRepository.getByPublishedFalse();

        for(OutBoxEvent event: events){

            try {

                DeliveryPartnerCreatedEvent e =
                        objectMapper.readValue(event.getPayload(), DeliveryPartnerCreatedEvent.class);

                deliveryPartnerEventPublisher.publish(e);
                log.info(
                        "Published delivery-partner-created event"
                );
                event.setPublished(true);
                outBoxEventRepository.save(event);

            }catch (Exception ex){
                log.error(
                        "Failed to publish delivery-partner-created event: {}",
                        ex.getMessage()
                );
            }
        }
    }
}
