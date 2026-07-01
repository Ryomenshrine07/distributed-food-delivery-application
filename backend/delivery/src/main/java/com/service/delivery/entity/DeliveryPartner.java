package com.service.delivery.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import lombok.*;

import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Operational read-model / aggregate for a delivery partner inside the Delivery domain.
 *
 * <p>This entity intentionally holds ONLY the fields the Delivery domain needs to operate.
 * Identity, credentials and profile data (email, password, role, vehicle, license, ...)
 * are owned by the Auth Service and are deliberately NOT duplicated here.
 *
 * <p>The {@code id} is NOT generated locally: it is the same identifier issued by the
 * Auth Service and arrives via the {@code DeliveryPartnerCreatedEvent}. This keeps a
 * single source of truth for identity while letting the Delivery domain own operational
 * state (availability, online status, current assignment).
 *
 * <p>Fast-changing geo coordinates are NOT stored here. The live location is owned by
 * Redis GEO (see {@code RedisLocationService}); persisting every GPS ping into PostgreSQL
 * would create a second source of truth and hammer the relational store.
 */
@Entity
@Table(name = "delivery_partners")
@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class DeliveryPartner {

    /** Same identity as the Auth Service partner; supplied by the inbound event, never generated locally. */
    @Id
    private UUID id;

    private String name;

    private String phone;

    /** Eligible to receive a new assignment. Mutated ONLY by the Delivery service layer. */
    @Column(nullable = false)
    private boolean available;

    /** Connected to the platform (app open / sending heartbeats). Operational only. */
    @Column(nullable = false)
    private boolean online;

    /** The assignment the partner is currently working on, or {@code null} when free. */
    private UUID currentAssignmentId;

    /** Last time the partner was seen (heartbeat / location ping). */
    private OffsetDateTime lastSeen;

    private OffsetDateTime createdAt;

    private OffsetDateTime updatedAt;

    /* ----------------------------------------------------------------------
     * Domain behaviour.
     *
     * The service layer decides WHEN a transition happens; the aggregate owns
     * HOW its state changes so the invariants stay in one place.
     * -------------------------------------------------------------------- */

    /** Reserve this partner for an assignment. */
    public void markUnavailable(UUID assignmentId) {
        this.available = false;
        this.currentAssignmentId = assignmentId;
    }

    /** Release this partner so they can take new orders again (flow step 9). */
    public void markAvailable() {
        this.available = true;
        this.currentAssignmentId = null;
    }

    public void goOnline() {
        this.online = true;
        this.lastSeen = OffsetDateTime.now();
    }

    public void goOffline() {
        this.online = false;
        this.lastSeen = OffsetDateTime.now();
    }

    /** Record a heartbeat (e.g. on a location update) and mark the partner connected. */
    public void heartbeat() {
        this.online = true;
        this.lastSeen = OffsetDateTime.now();
    }

    @PrePersist
    void onCreate() {
        OffsetDateTime now = OffsetDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    void onUpdate() {
        this.updatedAt = OffsetDateTime.now();
    }
}
