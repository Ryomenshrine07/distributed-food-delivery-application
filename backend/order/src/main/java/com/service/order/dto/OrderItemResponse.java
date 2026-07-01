package com.service.order.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record OrderItemResponse(

        UUID id,
        UUID menuItemId,
        String itemName,
        BigDecimal price,
        Integer quantity,
        BigDecimal totalPrice
) {
}