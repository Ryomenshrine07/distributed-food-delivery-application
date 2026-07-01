package com.service.auth.config;


import com.service.auth.topics.KafkaTopics;
import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class KafkaConfig {

    public NewTopic getDeliveryPartnerTopic(){
        return TopicBuilder
                .name(KafkaTopics.DELIVERY_PARTNER_CREATED)
                .build();
    }
}
