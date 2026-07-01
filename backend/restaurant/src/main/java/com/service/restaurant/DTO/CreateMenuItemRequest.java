package com.service.restaurant.DTO;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record CreateMenuItemRequest(

        @NotBlank(message = "Menu item name cannot be blank")
        String name,

        @NotBlank
        String description,

        @NotNull
        @DecimalMin(value = "0.0", inclusive = false, message = "Menu item price must be greater than zero")
        BigDecimal price,

        @NotNull
        Boolean vegetarian
) {
}
