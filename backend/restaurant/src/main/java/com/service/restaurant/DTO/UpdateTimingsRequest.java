package com.service.restaurant.DTO;

import jakarta.validation.constraints.NotNull;
import java.time.LocalTime;

public record UpdateTimingsRequest(
        @NotNull LocalTime openingTime,
        @NotNull LocalTime closingTime
) {}
