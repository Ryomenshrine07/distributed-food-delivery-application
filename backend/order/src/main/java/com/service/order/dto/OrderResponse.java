package com.service.order.dto;

import com.service.order.enums.OrderStatus;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

public record OrderResponse(

        UUID id,
        UUID customerId,
        String customerName,
        String customerPhone,
        String customerEmail,
        UUID restaurantId,
        UUID deliveryPartnerId,
        String deliveryPartnerName,
        String deliveryPartnerPhone,

        DeliveryLocationResponse deliveryLocation,

        BigDecimal subtotal,
        BigDecimal deliveryFee,
        BigDecimal tax,
        BigDecimal totalAmount,

        OrderStatus status,

        List<OrderItemResponse> items,

        OffsetDateTime createdAt
) {
}
