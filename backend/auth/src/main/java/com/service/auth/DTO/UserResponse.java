package com.service.auth.DTO;

import com.service.auth.enums.Role;

import java.util.UUID;

public record UserResponse(
        UUID id,
        String fullName,
        String email,
        String phone,
        Role role
) {
}
