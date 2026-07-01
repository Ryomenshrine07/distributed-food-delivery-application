package com.service.auth.DTO;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;



public record RegisterDeliveryPersonRequest(
        @Email
        @NotBlank
        String email,

        @NotBlank
        @Size(min = 8, max = 25, message = "Password length should be in range of 8-15 characters")
        String password,

        @NotBlank
        @Pattern(regexp = "^[6-9]\\d{9}$")
        String phone,

        @NotBlank
        String fullName
) {
}
