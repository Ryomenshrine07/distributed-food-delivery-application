package com.service.auth.service;


import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.auth.DTO.*;
import com.service.auth.Entities.DeliveryPerson;
import com.service.auth.Entities.OutBoxEvent;
import com.service.auth.Entities.User;
import com.service.auth.Repository.DeliveryPersonRepository;
import com.service.auth.Repository.OutBoxEventRepository;
import com.service.auth.Repository.UserRepository;
import com.service.auth.enums.Role;
import com.service.auth.event.DeliveryPartnerCreatedEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;


@Slf4j
@RequiredArgsConstructor
@Service
public class AuthService {
    private final PasswordEncoder passwordEncoder;
    private final  UserRepository userRepository;
    private final DeliveryPersonRepository deliveryPersonRepository;
    private final JwtService jwtService;
    private final ObjectMapper objectMapper;
    private final OutBoxEventRepository outBoxEventRepository;

    @Transactional
    public UserResponse registerCustomer(RegisterCustomerRequest request){
        if(userRepository.existsByEmail(request.email())){
            throw new IllegalArgumentException("Email Already Exists");
        }
        if(userRepository.existsByPhone(request.phone())){
            throw new IllegalArgumentException("Phone Already Exists");
        }
        User user = User.builder()
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .role(Role.CUSTOMER)
                .fullName(request.fullName())
                .phone(request.phone())
                .build();
        userRepository.save(user);
        return new UserResponse(
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getPhone(),
                user.getRole()
        );
    }

    @Transactional
    public UserResponse registerDeliveryPerson(RegisterDeliveryPersonRequest request){
        if(deliveryPersonRepository.existsByEmail(request.email())){
            throw new IllegalArgumentException("Email Already Exists");
        }
        if(deliveryPersonRepository.existsByPhone(request.phone())){
            throw new IllegalArgumentException("Phone Already Exists");
        }
        DeliveryPerson person = DeliveryPerson.builder()
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .role(Role.DELIVERY_PERSON)
                .fullName(request.fullName())
                .phone(request.phone())
                .build();
        deliveryPersonRepository.save(person);

        try{
            OutBoxEvent outBoxEvent = OutBoxEvent.builder()
                    .eventType("delivery-partner-created")
                    .aggregateId(person.getId())
                    .aggregateType("DELIVERY_PERSON")
                    .createdAt(OffsetDateTime.now())
                    .published(false)
                    .payload(objectMapper.writeValueAsString(
                            new DeliveryPartnerCreatedEvent(
                                    person.getId(),
                                    person.getFullName(),
                                    person.getPhone()
                            )
                    ))
                    .build();
            outBoxEventRepository.save(outBoxEvent);
            log.info(
                    "OutBox event saved for delivery-partner-created for: {}",
                    person.getId()
            );
        }catch (JsonProcessingException ex){
            log.error(
                    "Failed to save outbox event for delivery-partner-created: {}",
                    ex.getMessage()
            );
        }

        return new UserResponse(
                person.getId(),
                person.getFullName(),
                person.getEmail(),
                person.getPhone(),
                person.getRole()
        );
    }

    @Transactional
    public UserResponse registerAdmin(RegisterCustomerRequest request){
        if(userRepository.existsByEmail(request.email())){
            throw new IllegalArgumentException("Email Already Exists");
        }
        if(userRepository.existsByPhone(request.phone())){
            throw new IllegalArgumentException("Phone Already Exists");
        }
        User user = User.builder()
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .role(Role.ADMIN)
                .fullName(request.fullName())
                .phone(request.phone())
                .build();
        userRepository.save(user);
        return new UserResponse(
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getPhone(),
                user.getRole()
        );
    }

    @Transactional
    public UserResponse registerRestaurantOwner(RegisterCustomerRequest request){
        if(userRepository.existsByEmail(request.email())){
            throw new IllegalArgumentException("Email Already Exists");
        }
        if(userRepository.existsByPhone(request.phone())){
            throw new IllegalArgumentException("Phone Already Exists");
        }
        User user = User.builder()
                .email(request.email())
                .password(passwordEncoder.encode(request.password()))
                .role(Role.RESTAURANT_OWNER)
                .fullName(request.fullName())
                .phone(request.phone())
                .build();
        userRepository.save(user);
        return new UserResponse(
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getPhone(),
                user.getRole()
        );
    }

    public AuthResponse loginUser(LoginRequest request){
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() ->
                        new BadCredentialsException("Invalid credentials"));
        String pass = request.password();
        if(!passwordEncoder.matches(pass, user.getPassword())){
            throw new BadCredentialsException("Invalid Credentials");
        }
        return new AuthResponse(
                jwtService.generateToken(user),
                user.getId(),
                user.getFullName(),
                user.getEmail(),
                user.getRole()
        );
    }
    public AuthResponse loginDeliveryPerson(LoginRequest request){
        DeliveryPerson person = deliveryPersonRepository
                .findByEmail(request.email())
                .orElseThrow(() ->
                        new BadCredentialsException("Invalid credentials"));
        String pass = request.password();
        if(!passwordEncoder.matches(pass, person.getPassword())){
            throw new BadCredentialsException("Invalid Credentials");
        }
        return new AuthResponse(
                jwtService.generateToken(person),
                person.getId(),
                person.getFullName(),
                person.getEmail(),
                person.getRole()
        );
    }
    public java.util.List<UserResponse> getUsersByRole(Role role) {
        if (role == null) {
            return userRepository.findAll().stream()
                    .map(u -> new UserResponse(u.getId(), u.getFullName(), u.getEmail(), u.getPhone(), u.getRole()))
                    .toList();
        }
        return userRepository.findByRole(role).stream()
                .map(u -> new UserResponse(u.getId(), u.getFullName(), u.getEmail(), u.getPhone(), u.getRole()))
                .toList();
    }

    /**
     * Authoritative lookup of a delivery partner's identity/profile, used by the
     * Delivery service to backfill partners it never received an event for
     * (legacy riders registered before the outbox existed, cleared replicas, ...).
     */
    @Transactional(readOnly = true)
    public java.util.Optional<DeliveryPartnerCreatedEvent> findDeliveryPartner(java.util.UUID id) {
        return deliveryPersonRepository.findById(id)
                .map(p -> new DeliveryPartnerCreatedEvent(p.getId(), p.getFullName(), p.getPhone()));
    }
}
