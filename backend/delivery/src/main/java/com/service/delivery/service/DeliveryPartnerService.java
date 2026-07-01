package com.service.delivery.service;

import com.service.delivery.entity.DeliveryPartner;
import com.service.delivery.event.DeliveryPartnerCreatedEvent;
import com.service.delivery.repository.DeliveryAssignmentRepository;
import com.service.delivery.repository.DeliveryPartnerRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Single owner of delivery-partner operational state inside the Delivery domain.
 *
 * <p>Every availability/online transition flows through this service. Nothing outside the
 * Delivery domain (and specifically not the Auth Service) is ever notified when these
 * change: availability is high-frequency, delivery-only state, so there is deliberately
 * NO REST call or Kafka event published back to Auth from any method here.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class DeliveryPartnerService {

    private final DeliveryPartnerRepository deliveryPartnerRepository;

    private final DeliveryAssignmentRepository deliveryAssignmentRepository;

    private final RedisLocationService redisLocationService;

    private final com.service.delivery.client.AuthPartnerClient authPartnerClient;

    /**
     * Creates or refreshes the local operational replica when Auth announces a partner.
     * Upserts so that a previously-created stub (from {@link #getPartnerById}) is corrected
     * with the real name/phone, and redelivered events simply refresh the profile.
     */
    @Transactional
    public void syncFromAuth(DeliveryPartnerCreatedEvent event) {

        DeliveryPartner partner = deliveryPartnerRepository.findById(event.deliveryPartnerId())
                .orElse(null);

        if (partner == null) {
            partner = DeliveryPartner.builder()
                    .id(event.deliveryPartnerId())
                    .name(event.name())
                    .phone(event.phone())
                    .available(true)
                    .online(false)
                    .build();
        } else {
            // Auth owns identity/profile — refresh it, preserve operational state.
            partner.setName(event.name());
            partner.setPhone(event.phone());
        }

        deliveryPartnerRepository.save(partner);

        log.info("Delivery partner {} synced from Auth Service ({})",
                event.deliveryPartnerId(), event.name());
    }

    private final org.springframework.kafka.core.KafkaTemplate<String, Object> kafkaTemplate;

    /**
     * Records a live location heartbeat: live coordinates go to Redis GEO, while the
     * partner's online/lastSeen state is persisted. Availability is untouched here.
     */
    @Transactional
    public void updateLocation(UUID partnerId, double latitude, double longitude) {

        DeliveryPartner partner = getPartnerById(partnerId);
        deliveryPartnerRepository.save(partner);

        redisLocationService.updateLocation(partnerId, latitude, longitude);
        partner.heartbeat();

        UUID activeOrderId = null;
        if (partner.getCurrentAssignmentId() != null) {
            activeOrderId = deliveryAssignmentRepository.findById(partner.getCurrentAssignmentId())
                    .map(com.service.delivery.entity.DeliveryAssignment::getOrderId)
                    .orElse(null);
        }

        // High frequency telemetry, fire-and-forget to Kafka (skip Outbox for locations)
        java.util.Map<String, Object> locationUpdate = new java.util.HashMap<>();
        locationUpdate.put("riderId", partnerId);
        locationUpdate.put("orderId", activeOrderId);
        locationUpdate.put("latitude", latitude);
        locationUpdate.put("longitude", longitude);
        locationUpdate.put("timestamp", System.currentTimeMillis());
        
        kafkaTemplate.send("delivery.location.updated", partnerId.toString(), locationUpdate);

        log.debug("Location heartbeat recorded for partner {}", partnerId);
    }

    @Transactional
    public void goOnline(UUID partnerId) {
        DeliveryPartner partner = getPartnerById(partnerId);
        partner.goOnline();
        deliveryPartnerRepository.save(partner);
        log.info("Delivery partner {} is now ONLINE", partnerId);
    }

    @Transactional
    public void goOffline(UUID partnerId) {
        DeliveryPartner partner = getPartnerById(partnerId);
        partner.goOffline();
        deliveryPartnerRepository.save(partner);

        // An offline partner must not be discoverable by the nearby search.
        redisLocationService.removeLocation(partnerId);
        log.info("Delivery partner {} is now OFFLINE", partnerId);
    }

    /** Reserve a partner for an assignment. The ONLY path that sets available=false. */
    @Transactional
    public void markUnavailable(UUID partnerId, UUID assignmentId) {
        DeliveryPartner partner = getPartnerById(partnerId);
        partner.markUnavailable(assignmentId);
        deliveryPartnerRepository.save(partner);
        log.info("Delivery partner {} marked UNAVAILABLE for assignment {}", partnerId, assignmentId);
    }

    /** Release a partner after a delivery completes. The ONLY path that sets available=true post-assignment. */
    @Transactional
    public void markAvailable(UUID partnerId) {
        DeliveryPartner partner = getPartnerById(partnerId);
        partner.markAvailable();
        deliveryPartnerRepository.save(partner);
        log.info("Delivery partner {} marked AVAILABLE", partnerId);
    }

    public java.util.List<DeliveryPartner> getAllPartners() {
        return deliveryPartnerRepository.findAll();
    }

    public DeliveryPartner getPartnerById(UUID partnerId) {
        return deliveryPartnerRepository.findById(partnerId)
                .orElseGet(() -> createFromAuthOrStub(partnerId));
    }

    /**
     * Backfills a missing partner replica. Tries the authoritative Auth service first
     * (so the customer sees the real rider name/phone); only falls back to a placeholder
     * stub if Auth has no record or is unreachable.
     */
    private DeliveryPartner createFromAuthOrStub(UUID partnerId) {
        return authPartnerClient.fetchPartner(partnerId)
                .map(authPartner -> {
                    log.info("Backfilled delivery partner {} from Auth ({})",
                            partnerId, authPartner.name());
                    return deliveryPartnerRepository.save(DeliveryPartner.builder()
                            .id(partnerId)
                            .name(authPartner.name())
                            .phone(authPartner.phone())
                            .available(true)
                            .online(false)
                            .build());
                })
                .orElseGet(() -> {
                    log.warn("Delivery partner {} not found locally or in Auth. Creating stub record.",
                            partnerId);
                    return deliveryPartnerRepository.save(DeliveryPartner.builder()
                            .id(partnerId)
                            .name("Delivery Partner")
                            .phone("0000000000")
                            .available(true)
                            .online(false)
                            .build());
                });
    }

}
