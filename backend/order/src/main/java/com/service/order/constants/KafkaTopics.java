package com.service.order.constants;

public final class KafkaTopics {

    public static final String ORDER_CREATED = "order-created";

    public static final String ORDER_PREPARING = "order-preparing";

    public static final String ORDER_READY_FOR_PICKUP = "order-ready-for-pickup";

    public static final String PAYMENT_COMPLETED = "payment-completed";

    public static final String PAYMENT_FAILED = "payment-failed";

    public static final String DELIVERY_ASSIGNED = "delivery-assigned";

    public static final String ORDER_PICKED_UP = "order-picked-up";

    public static final String ORDER_DELIVERED = "order-delivered";

    private KafkaTopics() {}
}
