package com.service.payment.config;


import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;

@Configuration
public class RetryTopicConfig {

    @Bean
    public ThreadPoolTaskScheduler taskScheduler(){

        ThreadPoolTaskScheduler scheduler = new ThreadPoolTaskScheduler();
        scheduler.setPoolSize(3);
        scheduler.setThreadNamePrefix("retry-scheduler-");
        scheduler.initialize();

        return scheduler;
    }
}
