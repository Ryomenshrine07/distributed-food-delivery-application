package com.service.delivery.controller;

import com.service.delivery.service.DeliveryAssignmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

/**
 * Operational surface the rider's app calls to advance a delivery's lifecycle.
 *
 * <p>The Delivery Service is the source of truth for delivery status, so these inbound
 * calls trigger the state change and the corresponding outbound event (picked-up /
 * delivered) via the transactional outbox. Marking an order delivered also frees the
 * rider - that availability change stays entirely inside the Delivery domain.
 *
 * <p>As with the partner controller, these endpoints rely on the API Gateway for auth.
 */
@RestController
@RequestMapping("/api/delivery/assignments")
@RequiredArgsConstructor
public class DeliveryAssignmentController {

    private final DeliveryAssignmentService deliveryAssignmentService;

    @PostMapping("/{orderId}/picked-up")
    public ResponseEntity<Void> markPickedUp(
            @PathVariable UUID orderId,
            @org.springframework.web.bind.annotation.RequestHeader("X-User-Id") UUID partnerId) {
        deliveryAssignmentService.markPickedUp(orderId, partnerId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{orderId}/delivered")
    public ResponseEntity<Void> markDelivered(
            @PathVariable UUID orderId,
            @org.springframework.web.bind.annotation.RequestHeader("X-User-Id") UUID partnerId) {
        deliveryAssignmentService.completeDelivery(orderId, partnerId);
        return ResponseEntity.ok().build();
    }

    @org.springframework.web.bind.annotation.GetMapping("/offers")
    public ResponseEntity<java.util.List<com.service.delivery.entity.DeliveryAssignment>> getOffers(
            @org.springframework.web.bind.annotation.RequestHeader("X-User-Id") UUID partnerId) {
        return ResponseEntity.ok(deliveryAssignmentService.getPendingOffers(partnerId));
    }

    @PostMapping("/{orderId}/accept")
    public ResponseEntity<Void> acceptOffer(
            @PathVariable UUID orderId,
            @org.springframework.web.bind.annotation.RequestHeader("X-User-Id") UUID partnerId) {
        deliveryAssignmentService.acceptOffer(orderId, partnerId);
        return ResponseEntity.ok().build();
    }
}
