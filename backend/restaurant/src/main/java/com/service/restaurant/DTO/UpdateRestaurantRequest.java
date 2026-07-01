package com.service.restaurant.DTO;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateRestaurantRequest(
        @NotBlank(message = "Restaurant name cannot be blank")
        @Size(min = 3, max = 100, message = "Restaurant name must be between 3 and 100 characters")
        String name,
        String description,
        @NotBlank String phone,
        @NotBlank String address,
        @NotBlank String city,
        String cuisine,
        Double latitude,
        Double longitude,
        Integer averageDeliveryTime
) {}
