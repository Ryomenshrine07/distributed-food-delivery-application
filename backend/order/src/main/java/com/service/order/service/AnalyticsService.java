package com.service.order.service;

import com.service.order.dto.AnalyticsResponse;
import com.service.order.entity.Order;
import com.service.order.enums.OrderStatus;
import com.service.order.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnalyticsService {
    private final OrderRepository orderRepository;

    public AnalyticsResponse getAnalytics() {
        List<Order> orders = orderRepository.findAll();
        long totalOrders = orders.size();
        
        BigDecimal totalRevenue = orders.stream()
                .filter(o -> o.getStatus() == OrderStatus.DELIVERED)
                .map(Order::getTotalAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        long pendingOrders = orders.stream()
                .filter(o -> o.getStatus() == OrderStatus.PENDING_PAYMENT || o.getStatus() == OrderStatus.PREPARING)
                .count();
                
        long deliveredOrders = orders.stream()
                .filter(o -> o.getStatus() == OrderStatus.DELIVERED)
                .count();

        return new AnalyticsResponse(totalOrders, totalRevenue, pendingOrders, deliveredOrders);
    }
}
