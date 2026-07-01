package com.service.auth.Entities;


import jakarta.persistence.*;
import lombok.*;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.UUID;

@Table(name = "outbox-events")
@Entity
@Getter
@Setter
@Service
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

