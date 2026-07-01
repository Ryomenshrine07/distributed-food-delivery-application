package com.service.restaurant.DTO;

import java.math.BigDecimal;
import java.util.UUID;

public record MenuItemDetailsResponse(

        UUID id,

        UUID restaurantId,

        String itemName,

        BigDecimal price,

        Boolean available
) {
}
