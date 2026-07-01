package com.service.auth.Controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/test")
public class TestController {

    @GetMapping("/public")
    public ResponseEntity<String> test(){
        return ResponseEntity.ok("HEHEHE");
    }

    @GetMapping("/customer")
    @PreAuthorize("hasRole('CUSTOMER')")
    public String customerAPE(){
        return "Customer";
    }

    @GetMapping("/delivery-person")
    @PreAuthorize("hasRole('DELIVERY_PERSON')")
    public String deliveryPersonAPI(){
        return "Delivery Person";
    }

    @GetMapping("/headers")
    public Map<String, String> headers(
            @RequestHeader("X-User-Id") String userId,
            @RequestHeader("X-User-Email") String email,
            @RequestHeader("X-User-Role") String role
    ) {
        return Map.of(
                "userId", userId,
                "email", email,
                "role", role
        );
    }
}
