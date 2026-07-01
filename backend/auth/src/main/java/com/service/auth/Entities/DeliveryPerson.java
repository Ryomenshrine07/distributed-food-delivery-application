package com.service.auth.Entities;

import com.service.auth.Utils.JwtUser;
import com.service.auth.enums.DeliveryStatus;
import com.service.auth.enums.Role;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(
        name = "delivery_persons",
        indexes = {
                @Index(name = "idx_delivery_email", columnList = "email", unique = true),
                @Index(name = "idx_delivery_phone", columnList = "phone", unique = true),
                @Index(name = "idx_delivery_status", columnList = "status")
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryPerson extends BaseEntity implements JwtUser {

    @Column(nullable = false, length = 100)
    private String fullName;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false, unique = true)
    private String phone;

    @Column(nullable = false)
    private String password;

    @Enumerated(EnumType.STRING)
    private Role role;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private DeliveryStatus status = DeliveryStatus.OFFLINE;

    @Column(nullable = false)
    private boolean active = true;

    @Override
    public UUID getId() {
        return id;
    }

    @Override
    public String getName() {
        return fullName;
    }

    @Override
    public String getPhone() {
        return phone;
    }
}