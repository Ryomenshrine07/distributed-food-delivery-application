package com.service.tracking.dto;

import java.util.UUID;

public record RiderLocationUpdate(
        UUID riderId,
        UUID orderId, // Can be null if the rider is just online but not assigned
        double latitude,
        double longitude,
        long timestamp
) {
}
