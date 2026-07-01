package com.service.payment.repository;

import com.service.payment.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface PaymentRepository
        extends JpaRepository<Payment, UUID> {

    boolean existsByOrderId(UUID orderId);
}
