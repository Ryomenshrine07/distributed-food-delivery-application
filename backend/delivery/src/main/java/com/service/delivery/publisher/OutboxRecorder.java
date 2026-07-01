package com.service.delivery.publisher;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.delivery.entity.OutBoxEvent;
import com.service.delivery.repository.OutBoxEventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Writes domain events into the transactional outbox.
 *
 * <p>Called from inside a business transaction so the outbox row is committed atomically
 * with the state change that produced it (the transactional-outbox pattern). Actual Kafka
 * publishing is done asynchronously by {@link OutBoxEventPublisher}; this class never talks
 * to Kafka and contains no business decisions - it only persists the intent to publish.
 */
@Component
@RequiredArgsConstructor
public class OutboxRecorder {

    private final OutBoxEventRepository outBoxEventRepository;

    private final ObjectMapper objectMapper;

    public void record(String eventType, String aggregateType, UUID aggregateId, Object payload) {
        try {
            OutBoxEvent outBoxEvent = OutBoxEvent.builder()
                    .eventType(eventType)
                    .aggregateType(aggregateType)
                    .aggregateId(aggregateId)
                    .payload(objectMapper.writeValueAsString(payload))
                    .published(false)
                    .createdAt(OffsetDateTime.now())
                    .build();

            outBoxEventRepository.save(outBoxEvent);
        } catch (JsonProcessingException ex) {
            // Roll back the surrounding business transaction: persisting state without its
            // outbox row would silently drop the event and break downstream services.
            throw new IllegalStateException(
                    "Failed to serialize outbox payload for event type " + eventType, ex);
        }
    }
}
