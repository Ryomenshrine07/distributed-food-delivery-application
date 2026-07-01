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
 * calls trigger the state change and the corresponding outbound event (picked-up) via the
 * transactional outbox.
 *
 * <p>Delivery <em>completion</em> is deliberately NOT exposed here: an order becomes
 * {@code DELIVERED} only when the owning customer confirms receipt (Order Service
 * {@code POST /orders/{id}/receive}). The delivery domain reacts to that customer
 * confirmation via the {@code order-delivered} event
 * ({@link com.service.delivery.consumer.OrderDeliveredConsumer}) to release the rider - riders
 * can no longer self-complete a delivery.
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

    @org.springframework.web.bind.annotation.GetMapping("/offers")
    public ResponseEntity<java.util.List<com.service.delivery.entity.DeliveryAssignment>> getOffers(
            @org.springframework.web.bind.annotation.RequestHeader("X-User-Id") UUID partnerId) {
        return ResponseEntity.ok(deliveryAssignmentService.getPendingOffers(partnerId));
    }

    /**
     * Read-only recovery endpoint: returns the caller's current in-flight assignment so the
     * rider's app can restore it after a reinstall wiped local storage.
     *
     * <p>{@code /current} is a distinct literal path that does not collide with the
     * {@code /{orderId}/...} mappings. Returns {@code 200} with the assignment when one is
     * active ({@code ASSIGNED} or {@code PICKED_UP}), or {@code 204 No Content} when the rider
     * has no active assignment. As with the other endpoints, auth is enforced by the API Gateway,
     * which injects the {@code X-User-Id} of the authenticated partner.
     */
    @org.springframework.web.bind.annotation.GetMapping("/current")
    public ResponseEntity<com.service.delivery.entity.DeliveryAssignment> getCurrentAssignment(
            @org.springframework.web.bind.annotation.RequestHeader("X-User-Id") UUID partnerId) {
        com.service.delivery.entity.DeliveryAssignment assignment =
                deliveryAssignmentService.getActiveAssignmentForPartner(partnerId);
        if (assignment == null) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.ok(assignment);
    }

    @PostMapping("/{orderId}/accept")
    public ResponseEntity<Void> acceptOffer(
            @PathVariable UUID orderId,
            @org.springframework.web.bind.annotation.RequestHeader("X-User-Id") UUID partnerId) {
        deliveryAssignmentService.acceptOffer(orderId, partnerId);
        return ResponseEntity.ok().build();
    }
}
