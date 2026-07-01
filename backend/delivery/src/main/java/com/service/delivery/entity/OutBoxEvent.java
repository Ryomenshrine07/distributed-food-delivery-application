package com.service.delivery.entity;


import jakarta.persistence.*;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Table(name = "outbox_events")
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class OutBoxEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    private String aggregateType;

    private UUID aggregateId;

    @Column(columnDefinition = "TEXT")
    private String payload;

    private boolean published;

    private String eventType;

    private OffsetDateTime createdAt;
}
