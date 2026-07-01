package com.service.delivery.service;

import com.service.delivery.entity.DeliveryAssignment;
import com.service.delivery.entity.DeliveryPartner;
import com.service.delivery.enums.DeliveryStatus;
import com.service.delivery.event.DeliveryAssignedEvent;
import com.service.delivery.event.OrderDeliveredEvent;
import com.service.delivery.event.OrderPickedUpEvent;
import com.service.delivery.event.OrderReadyForPickupEvent;
import com.service.delivery.event.PaymentCompletedEvent;
import com.service.delivery.publisher.OutboxRecorder;
import com.service.delivery.repository.DeliveryAssignmentRepository;
import com.service.delivery.repository.DeliveryPartnerRepository;
import com.service.delivery.topics.KafkaTopics;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Owns the delivery-assignment use-case: who gets an order, and the lifecycle transitions
 * (assigned -> picked up -> delivered). All decisions and persistence live here so the
 * Kafka consumers/producers stay thin adapters with no business logic.
 *
 * <p>Each method is a single transaction: the assignment write, the partner availability
 * change and the outbox row are committed atomically, preserving the transactional-outbox
 * guarantee.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DeliveryAssignmentService {

    /** How far from the restaurant to look for a rider before falling back. */
    private static final double SEARCH_RADIUS_KM = 5.0;

    /** Cap on candidates pulled from the geo index per assignment. */
    private static final int MAX_CANDIDATES = 10;

    private final DeliveryPartnerRepository deliveryPartnerRepository;

    private final DeliveryAssignmentRepository deliveryAssignmentRepository;

    private final DeliveryPartnerService deliveryPartnerService;

    private final RedisLocationService redisLocationService;

    private final OutboxRecorder outboxRecorder;

    /**
     * Reacts to a completed payment by creating a delivery shell that stays hidden
     * from riders until the restaurant marks the order ready for pickup.
     * Idempotent on orderId so a redelivered PaymentCompletedEvent is a no-op.
     */
    @Transactional
    public void assignDeliveryForPayment(PaymentCompletedEvent event) {

        if (deliveryAssignmentRepository.existsByOrderId(event.orderId())) {
            log.info("Delivery already created for order {}", event.orderId());
            return;
        }

        OffsetDateTime now = OffsetDateTime.now();
        DeliveryAssignment assignment = DeliveryAssignment.builder()
                .orderId(event.orderId())
                .customerId(event.customerId())
                .restaurantId(event.restaurantId())
                .restaurantLatitude(event.restaurantLocation().latitude())
                .restaurantLongitude(event.restaurantLocation().longitude())
                .status(DeliveryStatus.WAITING_FOR_PICKUP)
                .assignedAt(null)
                .createdAt(now)
                .updatedAt(now)
                .build();

        deliveryAssignmentRepository.save(assignment);
        log.info("Delivery assignment created for order {}; waiting for restaurant readiness", event.orderId());
    }

    /**
     * Restaurant has marked the order ready. Only now does the assignment become a rider offer.
     */
    @Transactional
    public void markReadyForPickup(OrderReadyForPickupEvent event) {
        DeliveryAssignment assignment = deliveryAssignmentRepository.findByOrderId(event.orderId())
                .orElseThrow(() -> new IllegalStateException(
                        "No delivery assignment found for ready order " + event.orderId()));

        if (assignment.getStatus() != DeliveryStatus.WAITING_FOR_PICKUP) {
            log.info("Ready event for order {} ignored because assignment is already {}",
                    event.orderId(), assignment.getStatus());
            return;
        }

        assignment.setStatus(DeliveryStatus.PENDING);
        assignment.setUpdatedAt(OffsetDateTime.now());

        log.info("Delivery offer for order {} is now available to nearby riders", event.orderId());
    }

    /** Rider has collected the order from the restaurant. */
    @Transactional
    public void markPickedUp(UUID orderId, UUID partnerId) {
        DeliveryAssignment assignment = getAssignment(orderId);
        ensureAssignedPartner(assignment, partnerId);

        if (assignment.getStatus() != DeliveryStatus.ASSIGNED) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Order must be assigned before it can be picked up"
            );
        }

        OffsetDateTime now = OffsetDateTime.now();
        assignment.setStatus(DeliveryStatus.PICKED_UP);
        assignment.setPickedUpAt(now);
        assignment.setUpdatedAt(now);

        outboxRecorder.record(
                KafkaTopics.ORDER_PICKED_UP,
                "ORDER",
                orderId,
                new OrderPickedUpEvent(orderId, assignment.getDeliveryPartnerId(), now)
        );

        log.info("Order {} picked up by partner {}", orderId, partnerId);
    }

    /**
     * Rider has delivered the order. This frees the rider (flow step 9) and publishes the
     * OrderDeliveredEvent - all within the Delivery domain, with no callback to Auth.
     */
    @Transactional
    public void completeDelivery(UUID orderId, UUID partnerId) {
        DeliveryAssignment assignment = getAssignment(orderId);
        ensureAssignedPartner(assignment, partnerId);

        if (assignment.getStatus() != DeliveryStatus.PICKED_UP) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Order must be picked up before it can be delivered"
            );
        }

        OffsetDateTime now = OffsetDateTime.now();
        assignment.setStatus(DeliveryStatus.DELIVERED);
        assignment.setDeliveredAt(now);
        assignment.setUpdatedAt(now);

        deliveryPartnerService.markAvailable(assignment.getDeliveryPartnerId());

        outboxRecorder.record(
                KafkaTopics.ORDER_DELIVERED,
                "ORDER",
                orderId,
                new OrderDeliveredEvent(orderId, assignment.getDeliveryPartnerId(), now)
        );

        log.info("Order {} delivered by partner {}; partner released",
                orderId, partnerId);
    }

    public List<DeliveryAssignment> getPendingOffers(UUID partnerId) {
        List<DeliveryAssignment> pending = deliveryAssignmentRepository.findByStatus(DeliveryStatus.PENDING);
        
        org.springframework.data.geo.Point partnerLoc = redisLocationService.getPartnerLocation(partnerId);
        if (partnerLoc == null) {
            return List.of();
        }

        return pending.stream().filter(assignment -> {
            if (assignment.getRestaurantLatitude() == null || assignment.getRestaurantLongitude() == null) {
                return false;
            }
            double lat1 = partnerLoc.getY();
            double lon1 = partnerLoc.getX();
            double lat2 = assignment.getRestaurantLatitude();
            double lon2 = assignment.getRestaurantLongitude();
            
            double r = 6371; // earth radius in km
            double dLat = Math.toRadians(lat2 - lat1);
            double dLon = Math.toRadians(lon2 - lon1);
            double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                       Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                       Math.sin(dLon / 2) * Math.sin(dLon / 2);
            double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            double d = r * c;
            
            return d <= SEARCH_RADIUS_KM;
        }).toList();
    }

    @Transactional
    public void acceptOffer(UUID orderId, UUID partnerId) {
        DeliveryAssignment assignment = getAssignment(orderId);

        if (assignment.getStatus() != DeliveryStatus.PENDING) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Order is not ready for pickup");
        }

        DeliveryPartner partner = deliveryPartnerService.getPartnerById(partnerId);

        OffsetDateTime now = OffsetDateTime.now();
        assignment.setDeliveryPartnerId(partnerId);
        assignment.setStatus(DeliveryStatus.ASSIGNED);
        assignment.setAssignedAt(now);
        assignment.setUpdatedAt(now);

        deliveryAssignmentRepository.save(assignment);

        deliveryPartnerService.markUnavailable(partnerId, assignment.getId());

        outboxRecorder.record(
                KafkaTopics.DELIVERY_ASSIGNED,
                "ORDER",
                orderId,
                new DeliveryAssignedEvent(orderId, partnerId, partner.getName(), partner.getPhone(), now)
        );

        log.info("Delivery partner {} accepted order {}", partnerId, orderId);
    }

    private DeliveryAssignment getAssignment(UUID orderId) {
        return deliveryAssignmentRepository.findByOrderId(orderId)
                .orElseThrow(() -> new IllegalStateException(
                        "No delivery assignment found for order " + orderId));
    }

    private void ensureAssignedPartner(DeliveryAssignment assignment, UUID partnerId) {
        if (assignment.getDeliveryPartnerId() == null ||
                !assignment.getDeliveryPartnerId().equals(partnerId)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "This order is assigned to another delivery partner"
            );
        }
    }
}
