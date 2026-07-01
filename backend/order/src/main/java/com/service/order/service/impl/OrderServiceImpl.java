package com.service.order.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.service.order.client.RestaurantClient;
import com.service.order.dto.*;
import com.service.order.entity.DeliveryLocation;
import com.service.order.entity.Order;
import com.service.order.entity.OrderItem;
import com.service.order.entity.OutBoxEvent;
import com.service.order.enums.OrderStatus;
import com.service.order.event.OrderCreatedEvent;
import com.service.order.producer.OrderEventProducer;
import com.service.order.repository.OrderRepository;
import com.service.order.repository.OutBoxRepository;
import com.service.order.service.OrderService;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional
public class OrderServiceImpl implements OrderService {

    private final OrderRepository orderRepository;

    private final RestaurantClient restaurantClient;

    private final OrderEventProducer orderEventProducer;

    private final ObjectMapper objectMapper;

    private final OutBoxRepository outBoxRepository;

    @Override
    @Transactional
    public OrderResponse createOrder(
            CreateOrderRequest request,
            UUID customerId,
            String customerName,
            String customerPhone,
            String customerEmail
    ) {

        BigDecimal subtotal = BigDecimal.ZERO;
        List<OrderItem> orderItems = new ArrayList<>();

        for (CreateOrderItemRequest itemRequest : request.items()) {

            MenuItemDetailsResponse menuItem = restaurantClient.getMenuItem(itemRequest.menuItemId());
            if (!menuItem.available()) {
                throw new IllegalStateException(
                        "Menu item is unavailable"
                );
            }
            if (!menuItem.restaurantId().equals(request.restaurantId())) {
                throw new IllegalArgumentException(
                        "Menu item does not belong to the selected restaurant"
                );
            }

            BigDecimal price = menuItem.price();

            BigDecimal totalPrice = price.multiply(
                    BigDecimal.valueOf(itemRequest.quantity())
            );

            subtotal = subtotal.add(totalPrice);

            OrderItem orderItem = OrderItem.builder()
                    .menuItemId(itemRequest.menuItemId())
                    .itemName(itemRequest.itemName())
                    .price(price)
                    .quantity(itemRequest.quantity())
                    .totalPrice(totalPrice)
                    .build();

            orderItems.add(orderItem);
        }

        BigDecimal deliveryFee = BigDecimal.valueOf(40);

        BigDecimal tax = subtotal.multiply(
                BigDecimal.valueOf(0.05)
        );

        BigDecimal totalAmount = subtotal
                .add(deliveryFee)
                .add(tax);

        Order order = Order.builder()
                .customerId(customerId)
                .restaurantId(request.restaurantId())
                .customerName(customerName)
                .customerEmail(customerEmail)
                .customerPhone(customerPhone)
                .deliveryAddress(request.deliveryAddress())
                .deliveryLocation(
                        DeliveryLocation.builder()
                                .address(request.deliveryLocation().address())
                                .latitude(request.deliveryLocation().latitude())
                                .longitude(request.deliveryLocation().longitude())
                                .build()
                )
                .subtotal(subtotal)
                .deliveryFee(deliveryFee)
                .tax(tax)
                .totalAmount(totalAmount)
                .status(OrderStatus.PENDING_PAYMENT)
                .build();

        orderItems.forEach(item -> item.setOrder(order));

        order.setItems(orderItems);

        Order savedOrder = orderRepository.save(order);

        RestaurantResponse restaurant = restaurantClient.getRestaurant(request.restaurantId());
        try{
            OutBoxEvent outBoxEvent =
                    OutBoxEvent.builder()
                            .aggregateId(savedOrder.getId())
                            .aggregateType("ORDER")
                            .eventType("order-created")
                            .payload(objectMapper.writeValueAsString(
                                    new OrderCreatedEvent(
                                            savedOrder.getId(),
                                            savedOrder.getCustomerId(),
                                            savedOrder.getRestaurantId(),
                                            savedOrder.getTotalAmount(),
                                            mapToDeliveryLocationResponse(order.getDeliveryLocation()),
                                            new RestaurantLocation(
                                                    restaurant.latitude(),
                                                    restaurant.longitude()
                                            )
                                    )
                            ))
                            .createdAt(OffsetDateTime.now())
                            .build();
            outBoxRepository.save(outBoxEvent);
            log.info(
                    "Outbox event (order-created) saved for order: {}",
                    savedOrder.getId()
            );
        }catch (JsonProcessingException ex){
            throw new RuntimeException("Failed to serialize OrderCreatedEvent", ex);
        }
        return new OrderResponse(
                savedOrder.getId(),
                savedOrder.getCustomerId(),
                savedOrder.getCustomerName(),
                savedOrder.getCustomerPhone(),
                savedOrder.getCustomerEmail(),
                savedOrder.getRestaurantId(),
                savedOrder.getDeliveryPartnerId(),
                savedOrder.getDeliveryPartnerName(),
                savedOrder.getDeliveryPartnerPhone(),
                mapToDeliveryLocationResponse(savedOrder.getDeliveryLocation()),
                savedOrder.getSubtotal(),
                savedOrder.getDeliveryFee(),
                savedOrder.getTax(),
                savedOrder.getTotalAmount(),
                savedOrder.getStatus(),
                savedOrder.getItems()
                        .stream()
                        .map(item -> new OrderItemResponse(
                                item.getId(),
                                item.getMenuItemId(),
                                item.getItemName(),
                                item.getPrice(),
                                item.getQuantity(),
                                item.getTotalPrice()
                        ))
                        .toList(),
                savedOrder.getCreatedAt()
        );
    }

    @Override
    public OrderResponse getOrderById(UUID orderId, UUID userId, boolean isDeliveryPartner) {

        Order order = orderRepository.findById(orderId).orElseThrow(
                () -> new EntityNotFoundException("The order does not exists")
        );

        if(!isDeliveryPartner && !order.getCustomerId().equals(userId)){
            throw new AccessDeniedException("This is not your order");
        }
        return mapToOrderResponse(order);
    }

    @Override
    public List<OrderResponse> getMyOrders(UUID customerId) {
        List<Order> orders = orderRepository.findByCustomerId(customerId);
        return orders
                .stream()
                .map(this::mapToOrderResponse)
                .toList();
    }

    @Override
    public List<OrderResponse> getAllOrders() {
        return orderRepository.findAll()
                .stream()
                .map(this::mapToOrderResponse)
                .toList();
    }

    @Override
    public OrderResponse cancelOrder(UUID orderId, UUID customerId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new EntityNotFoundException("Order does not exists"));
        if(!order.getCustomerId().equals(customerId)){
            throw new AccessDeniedException("This is not this customer's order");
        }

        if(order.getStatus() == OrderStatus.DELIVERED || order.getStatus() == OrderStatus.OUT_FOR_DELIVERY){
            throw new IllegalStateException("Order cannot be canceled now");
        }

        order.setStatus(OrderStatus.CANCELLED);
        return mapToOrderResponse(orderRepository.save(order));
    }

    public OrderItemResponse mapToOrderItemResponse(OrderItem item){
        return new OrderItemResponse(
                item.getId(),
                item.getMenuItemId(),
                item.getItemName(),
                item.getPrice(),
                item.getQuantity(),
                item.getTotalPrice()
        );
    }

    public OrderResponse mapToOrderResponse(Order order){
        return new OrderResponse(
                order.getId(),
                order.getCustomerId(),
                order.getCustomerName(),
                order.getCustomerPhone(),
                order.getCustomerEmail(),
                order.getRestaurantId(),
                order.getDeliveryPartnerId(),
                order.getDeliveryPartnerName(),
                order.getDeliveryPartnerPhone(),
                mapToDeliveryLocationResponse(order.getDeliveryLocation()),
                order.getSubtotal(),
                order.getDeliveryFee(),
                order.getTax(),
                order.getTotalAmount(),
                order.getStatus(),
                order.getItems()
                        .stream()
                        .map(this::mapToOrderItemResponse)
                        .toList(),
                order.getCreatedAt()
        );
    }
    private DeliveryLocationResponse mapToDeliveryLocationResponse(
            DeliveryLocation deliveryLocation
    ) {
        return new DeliveryLocationResponse(
                deliveryLocation.getAddress(),
                deliveryLocation.getLatitude(),
                deliveryLocation.getLongitude()
        );
    }

    @Override
    public void acceptOrder(UUID orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new EntityNotFoundException("Order does not exist"));
        
        if (order.getStatus() != OrderStatus.CONFIRMED) {
            throw new IllegalStateException("Order must be CONFIRMED to be accepted");
        }

        order.setStatus(OrderStatus.PREPARING);
        orderRepository.save(order);

        try {
            OutBoxEvent outBoxEvent = OutBoxEvent.builder()
                    .aggregateId(order.getId())
                    .aggregateType("ORDER")
                    .eventType("order-preparing")
                    .payload(objectMapper.writeValueAsString(
                            new com.service.order.event.OrderPreparingEvent(
                                    order.getId(),
                                    order.getRestaurantId(),
                                    OffsetDateTime.now()
                            )
                    ))
                    .createdAt(OffsetDateTime.now())
                    .build();
            outBoxRepository.save(outBoxEvent);
            log.info("Outbox event (order-preparing) saved for order: {}", order.getId());
        } catch (JsonProcessingException ex) {
            throw new RuntimeException("Failed to serialize OrderPreparingEvent", ex);
        }
    }

    @Override
    public void markOrderReady(UUID orderId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new EntityNotFoundException("Order does not exist"));
        
        if (order.getStatus() != OrderStatus.PREPARING) {
            throw new IllegalStateException("Order must be PREPARING to be marked ready");
        }

        order.setStatus(OrderStatus.READY_FOR_PICKUP);
        orderRepository.save(order);

        try {
            OutBoxEvent outBoxEvent = OutBoxEvent.builder()
                    .aggregateId(order.getId())
                    .aggregateType("ORDER")
                    .eventType("order-ready-for-pickup")
                    .payload(objectMapper.writeValueAsString(
                            new com.service.order.event.OrderReadyForPickupEvent(
                                    order.getId(),
                                    order.getRestaurantId(),
                                    OffsetDateTime.now()
                            )
                    ))
                    .createdAt(OffsetDateTime.now())
                    .build();
            outBoxRepository.save(outBoxEvent);
            log.info("Outbox event (order-ready-for-pickup) saved for order: {}", order.getId());
        } catch (JsonProcessingException ex) {
            throw new RuntimeException("Failed to serialize OrderReadyForPickupEvent", ex);
        }
    }

    @Override
    public void markOrderDelivered(UUID orderId, UUID customerId) {
        Order order = orderRepository.findById(orderId)
                .orElseThrow(() -> new EntityNotFoundException("Order does not exist"));
        
        if (!order.getCustomerId().equals(customerId)) {
            throw new AccessDeniedException("This is not this customer's order");
        }

        if (order.getStatus() != OrderStatus.OUT_FOR_DELIVERY) {
            throw new IllegalStateException("Order must be OUT_FOR_DELIVERY to be marked delivered");
        }

        order.setStatus(OrderStatus.DELIVERED);
        orderRepository.save(order);

        try {
            OutBoxEvent outBoxEvent = OutBoxEvent.builder()
                    .aggregateId(order.getId())
                    .aggregateType("ORDER")
                    .eventType("order-delivered")
                    .payload(objectMapper.writeValueAsString(
                            new com.service.order.event.OrderDeliveredEvent(
                                    order.getId(),
                                    order.getDeliveryPartnerId(),
                                    OffsetDateTime.now()
                            )
                    ))
                    .createdAt(OffsetDateTime.now())
                    .build();
            outBoxRepository.save(outBoxEvent);
            log.info("Outbox event (order-delivered) saved for order: {}", order.getId());
        } catch (JsonProcessingException ex) {
            throw new RuntimeException("Failed to serialize OrderDeliveredEvent", ex);
        }
    }
}
