package com.service.order.controller;

import com.service.order.dto.CreateOrderRequest;
import com.service.order.dto.OrderResponse;
import com.service.order.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;

    @PostMapping
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<OrderResponse> createOrder(
            @Valid @RequestBody CreateOrderRequest request,
            @RequestHeader("X-User-Id") UUID customerId,
            @RequestHeader("X-User-Email") String customerEmail,
            @RequestHeader("X-User-Name") String customerName,
            @RequestHeader("X-User-Phone") String customerPhone

    ) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(orderService.createOrder(request, customerId,customerName,customerPhone,customerEmail));
    }

    @GetMapping("/{orderId}")
    @PreAuthorize("hasAnyRole('CUSTOMER', 'DELIVERY_PERSON')")
    public ResponseEntity<OrderResponse> getOrderById(
            @PathVariable UUID orderId,
            @RequestHeader("X-User-Id") UUID userId,
            org.springframework.security.core.Authentication authentication
    ) {
        boolean isDeliveryPartner = authentication.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_DELIVERY_PERSON"));
        return ResponseEntity.ok(
                orderService.getOrderById(orderId, userId, isDeliveryPartner)
        );
    }

    @GetMapping("/my-orders")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<List<OrderResponse>> getMyOrders(
            @RequestHeader("X-User-Id") UUID customerId
    ) {

        return ResponseEntity.ok(
                orderService.getMyOrders(customerId)
        );
    }

    @GetMapping("/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<OrderResponse>> getAllOrders() {
        return ResponseEntity.ok(orderService.getAllOrders());
    }

    @PatchMapping("/{orderId}/cancel")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<OrderResponse> cancelOrder(
            @PathVariable UUID orderId,
            @RequestHeader("X-User-Id") UUID customerId
    ) {

        return ResponseEntity.ok(
                orderService.cancelOrder(orderId, customerId)
        );
    }

    @PostMapping("/{orderId}/accept")
    @PreAuthorize("hasAnyRole('RESTAURANT', 'ADMIN')")
    public ResponseEntity<Void> acceptOrder(
            @PathVariable UUID orderId
    ) {
        orderService.acceptOrder(orderId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{orderId}/ready")
    @PreAuthorize("hasAnyRole('RESTAURANT', 'ADMIN')")
    public ResponseEntity<Void> markOrderReady(
            @PathVariable UUID orderId
    ) {
        orderService.markOrderReady(orderId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{orderId}/receive")
    @PreAuthorize("hasRole('CUSTOMER')")
    public ResponseEntity<Void> markOrderDelivered(
            @PathVariable UUID orderId,
            @RequestHeader("X-User-Id") UUID customerId
    ) {
        orderService.markOrderDelivered(orderId, customerId);
        return ResponseEntity.ok().build();
    }
}