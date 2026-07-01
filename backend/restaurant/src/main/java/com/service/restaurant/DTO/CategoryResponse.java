package com.service.restaurant.DTO;

import java.util.List;

public record CategoryResponse(

        String id,
        String name,
        List<MenuItemResponse> items
) {
}
