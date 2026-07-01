package com.service.auth.DTO;

import com.service.auth.enums.Role;

import java.util.UUID;

public record AuthResponse(
        String token,
        UUID userId,
        String fullName,
        String email,
        Role role
) {}