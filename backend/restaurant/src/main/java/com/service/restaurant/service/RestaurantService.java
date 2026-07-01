package com.service.restaurant.service;

import com.service.restaurant.DTO.*;

import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

public interface RestaurantService {

    RestaurantResponse createRestaurant(
            CreateRestaurantRequest request
    );

    RestaurantResponse getRestaurantById(
            UUID restaurantId
    );

    Page<RestaurantResponse> getRestaurants(String city, String category, Pageable pageable);

    Page<RestaurantResponse> searchRestaurants(String keyword, Pageable pageable);

    CategoryResponse addCategory(
            UUID restaurantId,
            CreateCategoryRequest request
    );

    MenuItemResponse addMenuItem(
            UUID categoryId,
            CreateMenuItemRequest request
    );

    RestaurantResponse updateRestaurant(UUID id, UpdateRestaurantRequest request);
    RestaurantResponse updateStatus(UUID id, UpdateStatusRequest request);
    RestaurantResponse updateTimings(UUID id, UpdateTimingsRequest request);
    void softDelete(UUID id);
    RestaurantResponse uploadRestaurantImage(UUID id, String type, MultipartFile file);
    MenuItemResponse uploadMenuItemImage(UUID itemId, MultipartFile file);

    RestaurantResponse getRestaurantMenu(
            UUID restaurantId
    );
}
