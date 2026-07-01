package com.service.restaurant.service.impl;

import com.service.restaurant.DTO.*;
import com.service.restaurant.entity.MenuCategory;
import com.service.restaurant.entity.MenuItem;
import com.service.restaurant.entity.Restaurant;
import com.service.restaurant.exception.DuplicateResourceException;
import com.service.restaurant.exception.InvalidOperationException;
import com.service.restaurant.exception.ResourceNotFoundException;
import com.service.restaurant.repository.MenuCategoryRepository;
import com.service.restaurant.repository.MenuItemRepository;
import com.service.restaurant.repository.RestaurantRepository;
import com.service.restaurant.security.SecurityContextUtil;
import com.service.restaurant.service.ImageUploadService;
import com.service.restaurant.service.RestaurantService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class RestaurantServiceImpl implements RestaurantService {
    private final RestaurantRepository restaurantRepository;
    private final MenuCategoryRepository categoryRepository;
    private final MenuItemRepository menuItemRepository;
    private final SecurityContextUtil securityContextUtil;
    private final ImageUploadService imageUploadService;

    @Override
    public RestaurantResponse createRestaurant(CreateRestaurantRequest request) {
        UUID ownerId = securityContextUtil.getCurrentUserId();
        validateUniqueRestaurantName(ownerId, request.name(), null);
        validateTimings(request.openingTime(), request.closingTime());
        Restaurant restaurant = Restaurant.builder()
                .name(request.name().trim()).description(request.description()).phone(request.phone())
                .address(request.address()).city(request.city()).latitude(request.latitude())
                .longitude(request.longitude()).cuisine(request.cuisine())
                .openingTime(request.openingTime()).closingTime(request.closingTime())
                .open(true).active(true).deleted(false).rating(0.0)
                .averageDeliveryTime(30).ownerId(ownerId).build();
        return mapToRestaurantResponse(restaurantRepository.save(restaurant));
    }

    @Override
    @Transactional(readOnly = true)
    public RestaurantResponse getRestaurantById(UUID id) {
        return mapToRestaurantResponse(findCustomerRestaurant(id));
    }

    @Override
    @Transactional(readOnly = true)
    public Page<RestaurantResponse> getRestaurants(String city, String category, Pageable pageable) {
        Page<Restaurant> page;
        if (category != null && !category.isBlank()) {
            page = restaurantRepository.findCustomerRestaurantsByCategory(category.trim(), pageable);
        } else if (city != null && !city.isBlank()) {
            page = restaurantRepository.findByCityIgnoreCaseAndActiveTrueAndDeletedFalse(city.trim(), pageable);
        } else {
            page = restaurantRepository.findByActiveTrueAndDeletedFalse(pageable);
        }
        return page.map(this::mapToRestaurantResponse);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<RestaurantResponse> searchRestaurants(String keyword, Pageable pageable) {
        if (keyword == null || keyword.isBlank()) throw new InvalidOperationException("Search keyword cannot be blank");
        return restaurantRepository.searchCustomerRestaurants(keyword.trim(), pageable).map(this::mapToRestaurantResponse);
    }

    @Override
    public RestaurantResponse updateRestaurant(UUID id, UpdateRestaurantRequest request) {
        Restaurant restaurant = findOwnedRestaurant(id);
        validateUniqueRestaurantName(restaurant.getOwnerId(), request.name(), id);
        restaurant.setName(request.name().trim());
        restaurant.setDescription(request.description());
        restaurant.setPhone(request.phone());
        restaurant.setAddress(request.address());
        restaurant.setCity(request.city());
        restaurant.setCuisine(request.cuisine());
        restaurant.setLatitude(request.latitude());
        restaurant.setLongitude(request.longitude());
        restaurant.setAverageDeliveryTime(request.averageDeliveryTime());
        return mapToRestaurantResponse(restaurantRepository.save(restaurant));
    }

    @Override
    public RestaurantResponse updateStatus(UUID id, UpdateStatusRequest request) {
        Restaurant restaurant = findOwnedRestaurant(id);
        restaurant.setActive(request.active());
        return mapToRestaurantResponse(restaurantRepository.save(restaurant));
    }

    @Override
    public RestaurantResponse updateTimings(UUID id, UpdateTimingsRequest request) {
        validateTimings(request.openingTime(), request.closingTime());
        Restaurant restaurant = findOwnedRestaurant(id);
        restaurant.setOpeningTime(request.openingTime());
        restaurant.setClosingTime(request.closingTime());
        return mapToRestaurantResponse(restaurantRepository.save(restaurant));
    }

    @Override
    public void softDelete(UUID id) {
        Restaurant restaurant = findOwnedRestaurant(id);
        restaurant.setDeleted(true);
        restaurant.setActive(false);
        restaurantRepository.save(restaurant);
    }

    @Override
    public CategoryResponse addCategory(UUID restaurantId, CreateCategoryRequest request) {
        Restaurant restaurant = findOwnedRestaurant(restaurantId);
        if (categoryRepository.existsByRestaurantIdAndNameIgnoreCase(restaurantId, request.name().trim())) {
            throw new DuplicateResourceException("Category name already exists in this restaurant");
        }
        return mapToCategoryResponse(categoryRepository.save(MenuCategory.builder()
                .name(request.name().trim()).restaurant(restaurant).build()));
    }

    @Override
    public MenuItemResponse addMenuItem(UUID categoryId, CreateMenuItemRequest request) {
        MenuCategory category = categoryRepository.findById(categoryId)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found"));
        assertOwner(category.getRestaurant());
        if (category.getRestaurant().isDeleted()) throw new ResourceNotFoundException("Restaurant not found");
        if (menuItemRepository.existsByCategoryIdAndNameIgnoreCase(categoryId, request.name().trim())) {
            throw new DuplicateResourceException("Menu item name already exists in this category");
        }
        MenuItem item = MenuItem.builder().name(request.name().trim()).description(request.description())
                .price(request.price()).vegetarian(request.vegetarian()).available(true).category(category).build();
        return mapToMenuItemResponse(menuItemRepository.save(item));
    }

    @Override
    @Transactional(readOnly = true)
    public RestaurantResponse getRestaurantMenu(UUID restaurantId) {
        return mapToRestaurantResponse(findCustomerRestaurant(restaurantId));
    }

    @Override
    public RestaurantResponse uploadRestaurantImage(UUID id, String type, MultipartFile file) {
        Restaurant restaurant = findOwnedRestaurant(id);
        if (!"logo".equalsIgnoreCase(type) && !"cover".equalsIgnoreCase(type)) {
            throw new InvalidOperationException("Image type must be 'logo' or 'cover'");
        }
        String url = imageUploadService.upload(file, "restaurants/" + id);
        if ("logo".equalsIgnoreCase(type)) restaurant.setLogoUrl(url);
        else restaurant.setCoverImageUrl(url);
        return mapToRestaurantResponse(restaurantRepository.save(restaurant));
    }

    @Override
    public MenuItemResponse uploadMenuItemImage(UUID itemId, MultipartFile file) {
        MenuItem item = menuItemRepository.findById(itemId)
                .orElseThrow(() -> new ResourceNotFoundException("Menu item not found"));
        assertOwner(item.getCategory().getRestaurant());
        if (item.getCategory().getRestaurant().isDeleted()) {
            throw new ResourceNotFoundException("Restaurant not found");
        }
        item.setImageUrl(imageUploadService.upload(file, "menu-items/" + itemId));
        return mapToMenuItemResponse(menuItemRepository.save(item));
    }

    private Restaurant findCustomerRestaurant(UUID id) {
        return restaurantRepository.findByIdAndActiveTrueAndDeletedFalse(id)
                .orElseThrow(() -> new ResourceNotFoundException("Restaurant not found"));
    }

    private Restaurant findOwnedRestaurant(UUID id) {
        Restaurant restaurant = restaurantRepository.findByIdAndDeletedFalse(id)
                .orElseThrow(() -> new ResourceNotFoundException("Restaurant not found"));
        assertOwner(restaurant);
        return restaurant;
    }

    private void assertOwner(Restaurant restaurant) {
        String role = securityContextUtil.getCurrentUserRole();
        if ("ADMIN".equals(role)) {
            return;
        }
        if (!restaurant.getOwnerId().equals(securityContextUtil.getCurrentUserId())) {
            throw new AccessDeniedException("You cannot modify this restaurant");
        }
    }

    private void validateUniqueRestaurantName(UUID ownerId, String name, UUID excludedId) {
        boolean duplicate = excludedId == null
                ? restaurantRepository.existsByOwnerIdAndNameIgnoreCaseAndDeletedFalse(ownerId, name.trim())
                : restaurantRepository.existsByOwnerIdAndNameIgnoreCaseAndDeletedFalseAndIdNot(ownerId, name.trim(), excludedId);
        if (duplicate) throw new DuplicateResourceException("Restaurant name already exists for this owner");
    }

    private void validateTimings(java.time.LocalTime opening, java.time.LocalTime closing) {
        if (opening != null && closing != null && !opening.isBefore(closing)) {
            throw new InvalidOperationException("Opening time must be before closing time");
        }
        if ((opening == null) != (closing == null)) {
            throw new InvalidOperationException("Opening time and closing time must be provided together");
        }
    }

    private RestaurantResponse mapToRestaurantResponse(Restaurant r) {
        return new RestaurantResponse(r.getId().toString(), r.getName(), r.getDescription(), r.getAddress(),
                r.getCity(), r.getOpen(), r.getAverageDeliveryTime(), r.getRating(), r.getImageUrl(),
                r.getLogoUrl(), r.getCoverImageUrl(), r.getCuisine(), r.getLatitude(), r.getLongitude(),
                r.isActive(), r.getOpeningTime(),
                r.getClosingTime(), r.getCreatedAt(), r.getUpdatedAt(),
                r.getCategories() == null ? List.of() : r.getCategories().stream().map(this::mapToCategoryResponse).toList());
    }

    private CategoryResponse mapToCategoryResponse(MenuCategory c) {
        return new CategoryResponse(c.getId().toString(), c.getName(),
                c.getItems() == null ? List.of() : c.getItems().stream().map(this::mapToMenuItemResponse).toList());
    }

    private MenuItemResponse mapToMenuItemResponse(MenuItem i) {
        return new MenuItemResponse(i.getId().toString(), i.getName(), i.getDescription(), i.getPrice(),
                i.getAvailable(), i.getVegetarian(), i.getImageUrl());
    }
}
