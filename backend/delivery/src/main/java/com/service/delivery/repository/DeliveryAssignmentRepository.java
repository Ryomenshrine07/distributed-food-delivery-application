package com.service.delivery.repository;

import com.service.delivery.entity.DeliveryAssignment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface DeliveryAssignmentRepository extends JpaRepository<DeliveryAssignment, UUID> {

    boolean existsByOrderId(UUID orderId);

    Optional<DeliveryAssignment> findByOrderId(UUID orderId);

    java.util.List<DeliveryAssignment> findByStatus(com.service.delivery.enums.DeliveryStatus status);

    /**
     * The partner's most recent in-flight assignment among the given statuses, if any.
     *
     * <p>Used by the read-only recovery lookup so the rider's app can restore an active
     * assignment after a reinstall wiped its local cache. Ordering by {@code assignedAt}
     * descending returns the latest accepted assignment first; callers pass the active
     * (unfinished) statuses.
     */
    Optional<DeliveryAssignment> findFirstByDeliveryPartnerIdAndStatusInOrderByAssignedAtDesc(
            UUID deliveryPartnerId,
            java.util.List<com.service.delivery.enums.DeliveryStatus> statuses);
}
