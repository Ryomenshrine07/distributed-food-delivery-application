package com.service.restaurant.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.time.LocalDateTime;
import java.time.LocalTime;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Entity
@Table(
        name = "restaurants",
        indexes = {
                @Index(name = "idx_restaurant_city", columnList = "city"),
                @Index(name = "idx_restaurant_owner", columnList = "owner_id"),
                @Index(name = "idx_restaurant_active", columnList = "active"),
                @Index(name = "idx_restaurant_deleted", columnList = "deleted"),
                @Index(name = "idx_restaurant_cuisine", columnList = "cuisine"),
                @Index(name = "idx_restaurant_name", columnList = "name"),
                @Index(name = "idx_restaurant_customer_city", columnList = "active, deleted, city")
        }
)
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Restaurant {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    private String description;

    @Column(nullable = false)
    private String phone;

    @Column(nullable = false)
    private String address;

    private String city;

    private Double latitude;

    private Double longitude;

    @Column(nullable = false)
    private Boolean open;

    private Integer averageDeliveryTime;

    private Double rating;

    private String imageUrl;

    private String logoUrl;

    private String coverImageUrl;

    private String cuisine;

    private LocalTime openingTime;

    private LocalTime closingTime;

    @OneToMany(
            mappedBy = "restaurant",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    @Builder.Default
    private List<MenuCategory> categories = new ArrayList<>();

    @Builder.Default
    @Column(nullable = false, columnDefinition = "boolean default true")
    private boolean active = true;

    @Builder.Default
    @Column(nullable = false, columnDefinition = "boolean default false")
    private boolean deleted = false;

    @Column(name = "owner_id", nullable = false)
    private UUID ownerId;

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;
}
