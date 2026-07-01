package com.service.delivery.config;

import com.service.delivery.event.DeliveryPartnerCreatedEvent;
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
}
