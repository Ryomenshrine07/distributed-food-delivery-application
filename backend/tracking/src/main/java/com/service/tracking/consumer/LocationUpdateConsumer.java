package com.service.tracking.consumer;

import com.service.tracking.dto.RiderLocationUpdate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class LocationUpdateConsumer {

    private static final Logger log = LoggerFactory.getLogger(LocationUpdateConsumer.class);
    private final SimpMessagingTemplate messagingTemplate;

    public LocationUpdateConsumer(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    @KafkaListener(topics = "delivery.location.updated", groupId = "tracking-service")
    public void consumeLocationUpdate(RiderLocationUpdate update) {
        log.debug("Received location update for rider {}: {}, {}", update.riderId(), update.latitude(), update.longitude());
        
        // Broadcast to admin dashboard
        messagingTemplate.convertAndSend("/topic/admin/riders/location", update);
        
        // Broadcast to specific order tracking topic if assigned
        if (update.orderId() != null) {
            messagingTemplate.convertAndSend("/topic/orders/" + update.orderId() + "/location", update);
        }
    }
}
