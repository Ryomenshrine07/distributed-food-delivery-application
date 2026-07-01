package com.service.delivery.controller;

import com.service.delivery.dto.LocationUpdateRequest;
import com.service.delivery.service.DeliveryPartnerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * Operational surface the rider's app calls to drive the partner's own state.
 *
 * <p>These endpoints carry NO identity/auth concerns - authentication is the API Gateway's
 * and Auth Service's responsibility (the gateway already runs a JWT filter). At the service
 * level they are currently unauthenticated and assume they are only reachable through the
 * gateway; if the Delivery Service can be hit directly, add a gateway-trust / JWT check.
 */
@RestController
@RequestMapping("/api/delivery/partners")
@RequiredArgsConstructor
public class DeliveryPartnerController {

    private final DeliveryPartnerService deliveryPartnerService;

    /** Live GPS heartbeat: live coords -> Redis GEO, online/lastSeen -> PostgreSQL. */
    @PostMapping("/{id}/location")
    public ResponseEntity<Void> updateLocation(
            @PathVariable UUID id,
            @Valid @RequestBody LocationUpdateRequest request
    ) {
        deliveryPartnerService.updateLocation(id, request.latitude(), request.longitude());
        return ResponseEntity.accepted().build();
    }

    @PostMapping("/{id}/online")
    public ResponseEntity<Void> goOnline(@PathVariable UUID id) {
        deliveryPartnerService.goOnline(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{id}/offline")
    public ResponseEntity<Void> goOffline(@PathVariable UUID id) {
        deliveryPartnerService.goOffline(id);
        return ResponseEntity.ok().build();
    }

    @org.springframework.web.bind.annotation.GetMapping("/admin")
    public ResponseEntity<java.util.List<com.service.delivery.entity.DeliveryPartner>> getAllPartners() {
        return ResponseEntity.ok(deliveryPartnerService.getAllPartners());
    }

    @org.springframework.web.bind.annotation.GetMapping("/{id}")
    public ResponseEntity<com.service.delivery.entity.DeliveryPartner> getPartner(
            @PathVariable UUID id) {
        return ResponseEntity.ok(deliveryPartnerService.getPartnerById(id));
    }
}
