package com.service.order.dto;

public record DeliveryLocationResponse(

        String address,

        Double latitude,

        Double longitude
) {
}