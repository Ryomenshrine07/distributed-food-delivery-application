package com.service.restaurant.service;


import com.service.restaurant.DTO.MenuItemDetailsResponse;
import com.service.restaurant.entity.MenuItem;
import com.service.restaurant.repository.MenuItemRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MenuItemService {

    private final MenuItemRepository menuItemRepository;


    @Transactional(readOnly = true)
    public MenuItemDetailsResponse getMenuItemDetails(
            UUID menuItemId
    ) {

        MenuItem item = menuItemRepository.findDetailsById(menuItemId)
                .orElseThrow(() ->
                        new EntityNotFoundException("Menu item not found"));

        return new MenuItemDetailsResponse(
                item.getId(),
                item.getCategory().getRestaurant().getId(),
                item.getName(),
                item.getPrice(),
                item.getAvailable()
        );
    }
}
