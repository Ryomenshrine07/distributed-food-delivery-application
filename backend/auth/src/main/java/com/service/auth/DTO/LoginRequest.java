package com.service.auth.DTO;


import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LoginRequest(
        @Email
        @NotBlank
        String email,

        @NotBlank
        @Size(min = 8, max = 15, message = "Password length should be in range of 8-15 characters")
        String password
) {

}
