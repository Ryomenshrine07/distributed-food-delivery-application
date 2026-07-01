package com.service.order.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateOrderItemRequest(

        @NotNull
        UUID menuItemId,

        @NotNull
        String itemName,

        @NotNull
        @Min(1)
        Integer quantity
) {
}