package com.service.apiGateway.service;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.UUID;

@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secret;

    @Value("${jwt.expiration}")
    private Long expiration;


    private SecretKey getSecretKey() {
        return Keys.hmacShaKeyFor(
                secret.getBytes(StandardCharsets.UTF_8)
        );
    }

    private Claims getUserClaims(String token) {
        return Jwts.parser()
                .verifyWith(getSecretKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    public String extractUsername(String token) {
        return getUserClaims(token)
                .getSubject();
    }

    public Date getExpirationTime(String token) {
        return getUserClaims(token)
                .getExpiration();
    }

    public boolean isTokenExpired(String token) {
        return getExpirationTime(token).before(new Date());
    }

    public UUID extractUserId(String token){
        return UUID.fromString(getUserClaims(token)
                .get("id", String.class));
    }

    public String extractRole(String token){
        return getUserClaims(token)
                .get("role", String.class);
    }

    public String extractPhone(String token){
        return getUserClaims(token)
                .get("phone", String.class);
    }

    public String extractName(String token){
        return getUserClaims(token)
                .get("name", String.class);
    }

    public boolean isTokenValid(String token) {
        return !isTokenExpired(token);
    }
}
