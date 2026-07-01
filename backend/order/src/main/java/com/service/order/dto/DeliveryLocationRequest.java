package com.service.order.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record DeliveryLocationRequest(

        @NotBlank
        String address,

        @NotNull
        Double latitude,

        @NotNull
        Double longitude
) {
}