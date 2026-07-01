package com.service.restaurant.config;


import com.service.restaurant.topics.KafkaTopics;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaConfig {

    @Bean
    public NewTopic getOrderPreparingTopic(){
        return TopicBuilder
                .name(KafkaTopics.ORDER_PREPARING)
                .build();
    }

    @Bean
    public NewTopic getOrderReadyForPickUpTopic(){
        return TopicBuilder
                .name(KafkaTopics.ORDER_READY_FOR_PICKUP)
                .build();
    }

    @Bean
    public NewTopic getOrderCancelledTopic(){
        return TopicBuilder
                .name(KafkaTopics.ORDER_CANCELLED)
                .build();
    }
}
