package com.service.restaurant.DTO;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.LocalTime;

public record CreateRestaurantRequest(

        @NotBlank(message = "Restaurant name cannot be blank")
        @Size(min = 3, max = 100, message = "Restaurant name must be between 3 and 100 characters")
        String name,

        String description,

        @NotBlank
        String phone,

        @NotBlank
        String address,

        @NotBlank
        String city,

        @NotNull
        Double latitude,

        @NotNull
        Double longitude,

        String cuisine,

        LocalTime openingTime,

        LocalTime closingTime
) {
}
