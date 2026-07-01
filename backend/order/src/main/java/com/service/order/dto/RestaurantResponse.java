package com.service.order.dto;

import java.util.UUID;

public record RestaurantResponse(
        UUID id,
        String name,
        String address,
        double latitude,
        double longitude
) {}
