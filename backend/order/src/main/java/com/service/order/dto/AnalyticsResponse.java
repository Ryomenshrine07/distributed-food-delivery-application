package com.service.order.dto;

import java.math.BigDecimal;

public record AnalyticsResponse(
        long totalOrders,
        BigDecimal totalRevenue,
        long pendingOrders,
        long deliveredOrders
) {
}
