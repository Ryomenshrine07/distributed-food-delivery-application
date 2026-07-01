package com.service.auth.service;


import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
@RequiredArgsConstructor
public class RateLimiter {

    private final StringRedisTemplate redisTemplate;

    public boolean isAllowed(
            String key,
            long maxRequests,
            Duration window
    ){
        Long currCount = redisTemplate.opsForValue().increment(key);
        if(currCount == null) return false;
        if(currCount == 1) redisTemplate.expire(key, window);
        return currCount <= maxRequests;
    }
}
