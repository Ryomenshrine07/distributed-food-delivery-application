package com.service.auth.Utils;

import com.service.auth.enums.Role;

import java.util.UUID;

public interface JwtUser {
    UUID getId();
    Role getRole();
    String getEmail();
    String getName();
    String getPhone();
}
