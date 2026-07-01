package com.service.delivery.config;


import com.service.delivery.topics.KafkaTopics;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaConfig {

    @Bean
    public NewTopic getDeliveryTopic(){
        return TopicBuilder
                .name(KafkaTopics.DELIVERY_ASSIGNED)
                .build();
    }
    @Bean
    public NewTopic getOrderPickUpTopic(){
        return TopicBuilder
                .name(KafkaTopics.ORDER_PICKED_UP)
                .build();
    }
    @Bean
    public NewTopic getOrderDeliveredTopic(){
        return TopicBuilder
                .name(KafkaTopics.ORDER_DELIVERED)
                .build();
    }

    @Bean
    public NewTopic getPaymentCompletedTopic(){
        return TopicBuilder
                .name(KafkaTopics.PAYMENT_COMPLETED)
                .build();
    }

    @Bean
    public NewTopic getOrderReadyForPickupTopic(){
        return TopicBuilder
                .name(KafkaTopics.ORDER_READY_FOR_PICKUP)
                .build();
    }

    @Bean
    public NewTopic getDeliveryPartnerCreatedTopic(){
        return TopicBuilder
                .name(KafkaTopics.DELIVERY_PARTNER_CREATED)
                .build();
    }
}
