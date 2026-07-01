package com.service.auth.DTO;


import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;



public record RegisterCustomerRequest(
        @Email
        @NotBlank
        String email,

        @NotBlank
        @Size(min = 8, max = 25, message = "Password length should be in range of 8-15 characters")
        String password,

        @NotBlank
        String fullName,

        @NotBlank
        @Pattern(regexp = "^[6-9]\\d{9}$",
        message = "Invalid phone number only Indian Supported")
        String phone
) {


}
