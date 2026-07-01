package com.service.tracking.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;

@Configuration
@EnableKafka
public class KafkaConsumerConfig {
    // Configured via application.properties, EnableKafka enables the @KafkaListener annotation
}
