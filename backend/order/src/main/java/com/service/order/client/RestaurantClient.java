package com.service.order.client;

import com.service.order.dto.MenuItemDetailsResponse;
import com.service.order.dto.RestaurantResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.UUID;


@FeignClient(
        name = "restaurant-service",
        url = "${services.restaurant.url}"
)
public interface RestaurantClient {
    @GetMapping("/internal/menu-items/{menuItemId}")
    MenuItemDetailsResponse getMenuItem(
        @PathVariable UUID menuItemId
    );

    @GetMapping("/internal/restaurants/{restaurantId}")
    RestaurantResponse getRestaurant(
            @PathVariable UUID restaurantId
    );
}