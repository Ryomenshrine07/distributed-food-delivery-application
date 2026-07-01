package com.service.restaurant.DTO;

import java.util.List;
import java.time.LocalDateTime;
import java.time.LocalTime;

public record RestaurantResponse(

        String id,
        String name,
        String description,
        String address,
        String city,
        Boolean open,
        Integer averageDeliveryTime,
        Double rating,
        String imageUrl,
        String logoUrl,
        String coverImageUrl,
        String cuisine,
        Double latitude,
        Double longitude,
        boolean active,
        LocalTime openingTime,
        LocalTime closingTime,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        List<CategoryResponse> categories
) {
}
