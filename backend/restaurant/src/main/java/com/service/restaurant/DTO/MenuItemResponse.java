package com.service.restaurant.DTO;

import java.math.BigDecimal;

public record MenuItemResponse(

        String id,
        String name,
        String description,
        BigDecimal price,
        Boolean available,
        Boolean vegetarian,
        String imageUrl
) {
}
