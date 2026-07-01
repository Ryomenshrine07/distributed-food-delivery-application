package com.service.auth.DTO;

public class RegisterAdminRequest {
    String email;
    String password;
    final String role = "ROLE_ADMIN";
}
