package com.service.restaurant.controller;


import com.service.restaurant.DTO.MenuItemDetailsResponse;
import com.service.restaurant.service.MenuItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/internal/menu-items")
@RequiredArgsConstructor
public class InternalMenuItemController {

    private final MenuItemService menuItemService;

    @GetMapping("/{menuItemId}")
    public MenuItemDetailsResponse getMenuItem(
            @PathVariable UUID menuItemId
    ) {
        return menuItemService.getMenuItemDetails(menuItemId);
    }
}