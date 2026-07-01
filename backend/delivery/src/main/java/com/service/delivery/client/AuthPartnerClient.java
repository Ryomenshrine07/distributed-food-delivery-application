package com.service.delivery.client;

import com.service.delivery.event.DeliveryPartnerCreatedEvent;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.Optional;
import java.util.UUID;

/**
 * Fetches authoritative delivery-partner identity/profile (name, phone) from the
 * Auth service on demand.
 *
 * <p>Used to backfill partners the Delivery service has no local replica for - e.g.
 * riders who registered before the DeliveryPartnerCreatedEvent existed, or whose
 * replica was lost when the local store was reset. This makes partner identity
 * self-healing instead of degrading to a "Delivery Partner" stub.
 */
@Component
@Slf4j
public class AuthPartnerClient {

    private final RestClient restClient;

    public AuthPartnerClient(
            @Value("${services.auth.url:http://localhost:8081}") String authUrl) {
        this.restClient = RestClient.builder().baseUrl(authUrl).build();
    }

    /** Returns the partner's identity from Auth, or empty if not found / Auth unreachable. */
    public Optional<DeliveryPartnerCreatedEvent> fetchPartner(UUID partnerId) {
        try {
            DeliveryPartnerCreatedEvent event = restClient.get()
                    .uri("/auth/delivery-persons/{id}", partnerId)
                    .retrieve()
                    .body(DeliveryPartnerCreatedEvent.class);
            return Optional.ofNullable(event);
        } catch (Exception ex) {
            log.warn("Could not fetch delivery partner {} from Auth service: {}",
                    partnerId, ex.getMessage());
            return Optional.empty();
        }
    }
}
