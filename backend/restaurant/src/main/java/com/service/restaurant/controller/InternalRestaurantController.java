package com.service.restaurant.controller;

import com.service.restaurant.DTO.RestaurantResponse;
import com.service.restaurant.service.RestaurantService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/internal/restaurants")
@RequiredArgsConstructor
public class InternalRestaurantController {

    private final RestaurantService restaurantService;

    @GetMapping("/{restaurantId}")
    public RestaurantResponse getRestaurant(
            @PathVariable UUID restaurantId
    ) {
        return restaurantService.getRestaurantById(restaurantId);
    }
}
