package com.service.delivery.entity;

import com.service.delivery.enums.DeliveryStatus;
import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "delivery_assignments")
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DeliveryAssignment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true)
    private UUID orderId;

    @Column(nullable = false)
    private UUID customerId;

    @Column(nullable = false)
    private UUID restaurantId;

    @Column
    private Double restaurantLatitude;

    @Column
    private Double restaurantLongitude;

    @Column
    private UUID deliveryPartnerId;

    @Enumerated(EnumType.STRING)
    private DeliveryStatus status;

    private OffsetDateTime assignedAt;

    private OffsetDateTime pickedUpAt;

    private OffsetDateTime deliveredAt;

    private OffsetDateTime createdAt;

    private OffsetDateTime updatedAt;
}