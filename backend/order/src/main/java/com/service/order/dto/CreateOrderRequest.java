package com.service.order.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.UUID;

public record CreateOrderRequest(

        @NotNull
        UUID restaurantId,

        @Valid
        @NotNull
        DeliveryLocationRequest deliveryLocation,

        @NotBlank
        String deliveryAddress,

        @Valid
        @NotEmpty
        List<CreateOrderItemRequest> items
) {
}