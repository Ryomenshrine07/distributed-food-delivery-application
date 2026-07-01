package com.service.restaurant.security;

import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class SecurityContextUtil {
    private AuthenticatedUser currentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken
                || !(authentication.getPrincipal() instanceof AuthenticatedUser user)) {
            throw new org.springframework.security.access.AccessDeniedException("Authenticated user is required");
        }
        return user;
    }

    public UUID getCurrentUserId() { return currentUser().id(); }
    public String getCurrentUserEmail() { return currentUser().email(); }
    public String getCurrentUserRole() { return currentUser().role(); }
}
