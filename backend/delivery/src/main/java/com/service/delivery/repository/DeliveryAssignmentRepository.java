package com.service.delivery.repository;

import com.service.delivery.entity.DeliveryAssignment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface DeliveryAssignmentRepository extends JpaRepository<DeliveryAssignment, UUID> {

    boolean existsByOrderId(UUID orderId);

    Optional<DeliveryAssignment> findByOrderId(UUID orderId);

    java.util.List<DeliveryAssignment> findByStatus(com.service.delivery.enums.DeliveryStatus status);
}
