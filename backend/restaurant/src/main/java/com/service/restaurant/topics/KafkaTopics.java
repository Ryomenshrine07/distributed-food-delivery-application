package com.service.restaurant.topics;


import org.springframework.stereotype.Component;

@Component
public class KafkaTopics {

    public static final String ORDER_PREPARING = "order-preparing";
    public static final String ORDER_READY_FOR_PICKUP = "order-ready-for-pickup";
    public static final String ORDER_CANCELLED = "order-cancelled";
}
