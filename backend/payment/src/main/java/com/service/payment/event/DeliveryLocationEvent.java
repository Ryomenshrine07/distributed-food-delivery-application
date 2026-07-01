package com.service.payment.event;

public record DeliveryLocationEvent(

        String address,

        Double latitude,

        Double longitude
) {
}
