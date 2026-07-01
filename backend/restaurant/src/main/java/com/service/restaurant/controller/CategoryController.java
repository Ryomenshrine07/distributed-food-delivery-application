package com.service.restaurant.controller;

import com.service.restaurant.DTO.ApiResponse;
import com.service.restaurant.DTO.CreateMenuItemRequest;
import com.service.restaurant.DTO.MenuItemResponse;
import com.service.restaurant.service.RestaurantService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class CategoryController {
    private final RestaurantService restaurantService;

    @PostMapping("/categories/{categoryId}/items")
    @PreAuthorize("hasRole('RESTAURANT_OWNER')")
    public ResponseEntity<ApiResponse<MenuItemResponse>> addMenuItem(
            @PathVariable UUID categoryId, @Valid @RequestBody CreateMenuItemRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Menu item created successfully", restaurantService.addMenuItem(categoryId, request)));
    }

    @PostMapping(value = "/menu-items/{itemId}/image", consumes = "multipart/form-data")
    @PreAuthorize("hasRole('RESTAURANT_OWNER')")
    public ApiResponse<MenuItemResponse> uploadMenuItemImage(
            @PathVariable UUID itemId, @RequestPart("file") MultipartFile file) {
        return ApiResponse.success("Menu item image updated successfully", restaurantService.uploadMenuItemImage(itemId, file));
    }
}
