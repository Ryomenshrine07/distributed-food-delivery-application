package com.service.restaurant.controller;

import com.service.restaurant.DTO.*;
import com.service.restaurant.service.RestaurantService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@RestController
@RequestMapping("/restaurants")
@RequiredArgsConstructor
public class RestaurantController {
    private final RestaurantService restaurantService;

    @PostMapping
    @PreAuthorize("hasRole('RESTAURANT_OWNER')")
    public ResponseEntity<ApiResponse<RestaurantResponse>> createRestaurant(@Valid @RequestBody CreateRestaurantRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Restaurant created successfully", restaurantService.createRestaurant(request)));
    }

    @GetMapping("/{id}")
    public ApiResponse<RestaurantResponse> getRestaurantById(@PathVariable UUID id) {
        return ApiResponse.success("Restaurant fetched successfully", restaurantService.getRestaurantById(id));
    }

    @GetMapping
    public ApiResponse<Page<RestaurantResponse>> getRestaurants(
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String category,
            @PageableDefault(size = 10) Pageable pageable) {
        return ApiResponse.success("Restaurants fetched successfully", restaurantService.getRestaurants(city, category, pageable));
    }

    @GetMapping("/search")
    public ApiResponse<Page<RestaurantResponse>> searchRestaurants(
            @RequestParam String keyword, @PageableDefault(size = 10) Pageable pageable) {
        return ApiResponse.success("Restaurants fetched successfully", restaurantService.searchRestaurants(keyword, pageable));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('RESTAURANT_OWNER')")
    public ApiResponse<RestaurantResponse> updateRestaurant(@PathVariable UUID id, @Valid @RequestBody UpdateRestaurantRequest request) {
        return ApiResponse.success("Restaurant updated successfully", restaurantService.updateRestaurant(id, request));
    }

    @PatchMapping("/{id}/status")
    @PreAuthorize("hasAnyRole('RESTAURANT_OWNER', 'ADMIN')")
    public ApiResponse<RestaurantResponse> updateStatus(@PathVariable UUID id, @Valid @RequestBody UpdateStatusRequest request) {
        return ApiResponse.success("Restaurant status updated successfully", restaurantService.updateStatus(id, request));
    }

    @PatchMapping("/{id}/timings")
    @PreAuthorize("hasRole('RESTAURANT_OWNER')")
    public ApiResponse<RestaurantResponse> updateTimings(@PathVariable UUID id, @Valid @RequestBody UpdateTimingsRequest request) {
        return ApiResponse.success("Restaurant timings updated successfully", restaurantService.updateTimings(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('RESTAURANT_OWNER')")
    public ApiResponse<Void> deleteRestaurant(@PathVariable UUID id) {
        restaurantService.softDelete(id);
        return ApiResponse.success("Restaurant deleted successfully", null);
    }

    @PostMapping("/{restaurantId}/categories")
    @PreAuthorize("hasRole('RESTAURANT_OWNER')")
    public ResponseEntity<ApiResponse<CategoryResponse>> addCategory(
            @PathVariable UUID restaurantId, @Valid @RequestBody CreateCategoryRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(
                "Category created successfully", restaurantService.addCategory(restaurantId, request)));
    }

    @GetMapping("/{restaurantId}/menu")
    public ApiResponse<RestaurantResponse> getRestaurantMenu(@PathVariable UUID restaurantId) {
        return ApiResponse.success("Menu fetched successfully", restaurantService.getRestaurantMenu(restaurantId));
    }

    @PostMapping(value = "/{id}/images", consumes = "multipart/form-data")
    @PreAuthorize("hasRole('RESTAURANT_OWNER')")
    public ApiResponse<RestaurantResponse> uploadImage(
            @PathVariable UUID id, @RequestParam String type, @RequestPart("file") MultipartFile file) {
        return ApiResponse.success("Restaurant image updated successfully", restaurantService.uploadRestaurantImage(id, type, file));
    }
}
