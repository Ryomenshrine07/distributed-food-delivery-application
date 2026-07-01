package com.service.auth.Controllers;

import com.service.auth.DTO.*;
import com.service.auth.exceptions.RateLimitExceededException;
import com.service.auth.service.AuthService;
import com.service.auth.service.RateLimiter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.coyote.Response;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;

@RequestMapping("/auth")
@RestController
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;

    private final RateLimiter rateLimiter;

    @PostMapping("/register/customer")
    public ResponseEntity<UserResponse> registerUser(
            @Valid @RequestBody RegisterCustomerRequest request,
            HttpServletRequest servletRequest
    ){
        String customerIp = servletRequest.getRemoteAddr();
        String key = "register:" + customerIp;
        if(!rateLimiter.isAllowed(
                key,
                3,
                Duration.ofHours(1)
        )){
            throw new RateLimitExceededException("Too many requests, Try again after some time");
        }
        log.info("Customer registration request for email: {}", request.email());
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerCustomer(request));
    }

    @PostMapping("/register/delivery")
    public ResponseEntity<UserResponse> registerDeliveryPerson(
            @Valid @RequestBody RegisterDeliveryPersonRequest request,
            HttpServletRequest servletRequest
    ){
        String deliveryPersonIp = servletRequest.getRemoteAddr();
        String key = "register:" + deliveryPersonIp;
        if(!rateLimiter.isAllowed(
                key,
                3,
                Duration.ofHours(1)
        )){
            throw new RateLimitExceededException("Too many requests, Try again after some time");
        }
        log.info("Delivery person registering for email : {}", request.email());
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerDeliveryPerson(request));
    }

    @PostMapping("/register/admin")
    public ResponseEntity<UserResponse> registerAdmin(
            @Valid @RequestBody RegisterCustomerRequest request,
            HttpServletRequest servletRequest
    ){
        String adminIp = servletRequest.getRemoteAddr();
        String key = "register:" + adminIp;
        if(!rateLimiter.isAllowed(
                key,
                3,
                Duration.ofHours(1)
        )){
            throw new RateLimitExceededException("Too many requests, Try again after some time");
        }
        log.info("Admin registering for email : {}", request.email());
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerAdmin(request));
    }

    @PostMapping("/register/restaurant-owner")
    public ResponseEntity<UserResponse> registerRestaurantOwner(
            @Valid @RequestBody RegisterCustomerRequest request,
            HttpServletRequest servletRequest
    ){
//        String ownerIp = servletRequest.getRemoteAddr();
//        String key = "register:" + ownerIp;
//        if(!rateLimiter.isAllowed(
//                key,
//                3,
//                Duration.ofHours(1)
//        )){
//            throw new RateLimitExceededException("Too many requests, Try again after some time");
//        }
        log.info("Restaurant owner registering for email : {}", request.email());
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.registerRestaurantOwner(request));
    }

    @PostMapping("/login/customer")
    public ResponseEntity<AuthResponse> loginCustomer(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest
    ){
        String customerIp = servletRequest.getRemoteAddr();
        String key = "login:" + customerIp;
        if(!rateLimiter.isAllowed(
                key,
                5,
                Duration.ofMinutes(1)
        )){
            throw new RateLimitExceededException("Too many attempts, Please try again later");
        }
        log.info("Attempting login for Customer with email: {} ", request.email());
        return ResponseEntity.status(HttpStatus.OK).body(authService.loginUser(request));
    }

    @PostMapping("/login/delivery-person")
    public ResponseEntity<AuthResponse> loginDeliveryPerson(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest
    ){
        String deliveryIp = servletRequest.getRemoteAddr();
        String key = "login:" + deliveryIp;
        if(!rateLimiter.isAllowed(
                key,
                5,
                Duration.ofMinutes(1)
        )){
            throw new RateLimitExceededException("Too many attempts, Please try again later");
        }
        log.info("Attempting login for Delivery person with email: {} ", request.email());
        return ResponseEntity.status(HttpStatus.OK).body(authService.loginDeliveryPerson(request));
    }

    @PostMapping("/login/admin")
    public ResponseEntity<AuthResponse> loginAdmin(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest
    ){
        String adminIp = servletRequest.getRemoteAddr();
        String key = "login:" + adminIp;
        if(!rateLimiter.isAllowed(
                key,
                5,
                Duration.ofMinutes(1)
        )){
            throw new RateLimitExceededException("Too many attempts, Please try again later");
        }
        log.info("Attempting login for Admin with email: {} ", request.email());
        return ResponseEntity.status(HttpStatus.OK).body(authService.loginUser(request));
    }


    @PostMapping("/login/restaurant-owner")
    public ResponseEntity<AuthResponse> loginRestaurantOwner(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest servletRequest
    ){
        String ownerIp = servletRequest.getRemoteAddr();
        String key = "login:" + ownerIp;
        if(!rateLimiter.isAllowed(
                key,
                5,
                Duration.ofMinutes(1)
        )){
            throw new RateLimitExceededException("Too many attempts, Please try again later");
        }
        log.info("Attempting login for Restaurant owner with email: {} ", request.email());
        return ResponseEntity.status(HttpStatus.OK).body(authService.loginUser(request));
    }
    @GetMapping("/admin/users")
    @org.springframework.security.access.prepost.PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<java.util.List<UserResponse>> getUsersByRole(
            @RequestParam(required = false) com.service.auth.enums.Role role
    ) {
        return ResponseEntity.ok(authService.getUsersByRole(role));
    }

    /** Internal lookup so the Delivery service can resolve a partner's real name/phone. */
    @GetMapping("/delivery-persons/{id}")
    public ResponseEntity<com.service.auth.event.DeliveryPartnerCreatedEvent> getDeliveryPerson(
            @PathVariable java.util.UUID id
    ) {
        return authService.findDeliveryPartner(id)
                .map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
}
