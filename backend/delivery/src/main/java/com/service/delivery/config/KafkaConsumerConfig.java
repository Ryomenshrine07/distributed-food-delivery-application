package com.service.delivery.config;

import com.service.delivery.event.DeliveryPartnerCreatedEvent;
import com.service.delivery.event.OrderDeliveredEvent;
import com.service.delivery.event.OrderReadyForPickupEvent;
import com.service.delivery.event.PaymentCompletedEvent;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.support.serializer.JsonDeserializer;

@Configuration
public class KafkaConsumerConfig {

    private final KafkaProperties kafkaProperties;

    public KafkaConsumerConfig(KafkaProperties kafkaProperties) {
        this.kafkaProperties = kafkaProperties;
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, PaymentCompletedEvent>
    paymentCompletedFactory() {

        JsonDeserializer<PaymentCompletedEvent> deserializer =
                new JsonDeserializer<>(PaymentCompletedEvent.class);

        deserializer.addTrustedPackages("*");
        deserializer.setUseTypeHeaders(false);

        DefaultKafkaConsumerFactory<String, PaymentCompletedEvent> consumerFactory =
                new DefaultKafkaConsumerFactory<>(
                        kafkaProperties.buildConsumerProperties(null),
                        new StringDeserializer(),
                        deserializer
                );

        ConcurrentKafkaListenerContainerFactory<String, PaymentCompletedEvent> factory =
                new ConcurrentKafkaListenerContainerFactory<>();

        factory.setConsumerFactory(consumerFactory);

        return factory;
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, DeliveryPartnerCreatedEvent>
    deliveryPartnerCreatedFactory() {

        JsonDeserializer<DeliveryPartnerCreatedEvent> deserializer =
                new JsonDeserializer<>(DeliveryPartnerCreatedEvent.class);

        deserializer.addTrustedPackages("*");
        deserializer.setUseTypeHeaders(false);

        DefaultKafkaConsumerFactory<String, DeliveryPartnerCreatedEvent> consumerFactory =
                new DefaultKafkaConsumerFactory<>(
                        kafkaProperties.buildConsumerProperties(null),
                        new StringDeserializer(),
                        deserializer
                );

        ConcurrentKafkaListenerContainerFactory<String, DeliveryPartnerCreatedEvent> factory =
                new ConcurrentKafkaListenerContainerFactory<>();

        factory.setConsumerFactory(consumerFactory);

        return factory;
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, OrderReadyForPickupEvent>
    orderReadyForPickupFactory() {

        JsonDeserializer<OrderReadyForPickupEvent> deserializer =
                new JsonDeserializer<>(OrderReadyForPickupEvent.class);

        deserializer.addTrustedPackages("*");
        deserializer.setUseTypeHeaders(false);

        DefaultKafkaConsumerFactory<String, OrderReadyForPickupEvent> consumerFactory =
                new DefaultKafkaConsumerFactory<>(
                        kafkaProperties.buildConsumerProperties(null),
                        new StringDeserializer(),
                        deserializer
                );

        ConcurrentKafkaListenerContainerFactory<String, OrderReadyForPickupEvent> factory =
                new ConcurrentKafkaListenerContainerFactory<>();

        factory.setConsumerFactory(consumerFactory);

        return factory;
    }

    /**
     * Consumer factory for the {@code order-delivered} topic.
     *
     * <p>The event is emitted by the Order Service when the owning customer confirms
     * receipt; the {@link com.service.delivery.consumer.OrderDeliveredConsumer} reacts to it
     * to release the assigned rider. Configured identically to the other cross-service
     * factories ({@code setUseTypeHeaders(false)} + trust all packages) so the payload
     * deserializes into the delivery-side {@link OrderDeliveredEvent} regardless of the
     * producer's type headers. This adds a consumer only; the topic contract is unchanged.
     */
    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, OrderDeliveredEvent>
    orderDeliveredFactory() {

        JsonDeserializer<OrderDeliveredEvent> deserializer =
                new JsonDeserializer<>(OrderDeliveredEvent.class);

        deserializer.addTrustedPackages("*");
        deserializer.setUseTypeHeaders(false);

        DefaultKafkaConsumerFactory<String, OrderDeliveredEvent> consumerFactory =
                new DefaultKafkaConsumerFactory<>(
                        kafkaProperties.buildConsumerProperties(null),
                        new StringDeserializer(),
                        deserializer
                );

        ConcurrentKafkaListenerContainerFactory<String, OrderDeliveredEvent> factory =
                new ConcurrentKafkaListenerContainerFactory<>();

        factory.setConsumerFactory(consumerFactory);

        return factory;
    }
}
