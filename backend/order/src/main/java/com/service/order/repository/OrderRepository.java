package com.service.order.repository;

import com.service.order.entity.Order;
import com.service.order.enums.OrderStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, UUID> {

    List<Order> findByCustomerId(UUID customerId);

    List<Order> findByCustomerIdAndStatus(
            UUID customerId,
            OrderStatus status
    );
    Optional<Order> findById(UUID id);

    boolean existsByIdAndStatus(
            UUID id,
            OrderStatus status
    );

    boolean existsByIdAndStatusIn(
            UUID id,
            List<OrderStatus> statuses
    );

    boolean existsByIdAndStatusNot(
            UUID id,
            OrderStatus status
    );
}