package com.service.delivery.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/**
 * Inbound payload for a delivery partner's live location heartbeat.
 */
public record LocationUpdateRequest(

        @NotNull
        @Min(-90)
        @Max(90)
        Double latitude,

        @NotNull
        @Min(-180)
        @Max(180)
        Double longitude
) {}
