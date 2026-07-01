package com.service.order.service;


import com.service.order.entity.Order;
import com.service.order.enums.OrderStatus;
import com.service.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class OrderStatusUpdateService {

    private final OrderRepository orderRepository;

    @Transactional
    public void updateStatus(UUID orderId, OrderStatus status){

        Order order = orderRepository.findById(orderId)
                .orElseThrow(() ->
                        new RuntimeException("Order not found: " + orderId));
        order.setStatus(status);

        log.info("Order {} updated to {}", orderId, status);
    }
}
