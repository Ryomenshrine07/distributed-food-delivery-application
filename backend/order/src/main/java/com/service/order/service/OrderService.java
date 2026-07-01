package com.service.order.service;

import com.service.order.dto.CreateOrderRequest;
import com.service.order.dto.OrderResponse;

import java.util.List;
import java.util.UUID;

public interface OrderService {

    OrderResponse createOrder(CreateOrderRequest request,UUID customerId,
                              String customerName,
                              String customerPhone,
                              String customerEmail);

    OrderResponse getOrderById(UUID orderId, UUID userId, boolean isDeliveryPartner);

    List<OrderResponse> getMyOrders(UUID customerId);

    List<OrderResponse> getAllOrders();

    OrderResponse cancelOrder(UUID orderId, UUID customerId);

    void acceptOrder(UUID orderId);
    void markOrderReady(UUID orderId);
    void markOrderDelivered(UUID orderId, UUID customerId);
}