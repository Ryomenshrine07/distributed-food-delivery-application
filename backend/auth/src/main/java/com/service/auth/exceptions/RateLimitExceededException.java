package com.service.auth.exceptions;

public class RateLimitExceededException extends RuntimeException {
    public RateLimitExceededException(String message){
        super(message);
    }
}
