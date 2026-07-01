package com.service.apiGateway.filter;


import com.service.apiGateway.service.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;
import io.jsonwebtoken.JwtException;
import java.nio.charset.StandardCharsets;


@Component
@RequiredArgsConstructor
@Slf4j
public class JwtFilter implements GlobalFilter, Ordered{

    private final JwtService jwtService;
    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {

        log.info("JwtFilter executed for path: {}",
                exchange.getRequest().getPath().value());
        String path = String.valueOf(exchange.getRequest().getPath());
        if(path.startsWith("/auth/") || exchange.getRequest().getMethod().name().equals("OPTIONS")){
            return chain.filter(exchange);
        }
        log.info("Path: {}", path);
        String authHeader = exchange
                .getRequest()
                .getHeaders()
                .getFirst(HttpHeaders.AUTHORIZATION);

        if(authHeader == null || !authHeader.startsWith("Bearer ")){
            exchange.getResponse()
                    .setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        log.info("Authorization: {}", authHeader);

        String token = authHeader.substring(7);
        try {
            if (!jwtService.isTokenValid(token)) {
                exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
                return exchange.getResponse().setComplete();
            }
        } catch (JwtException ex) {
            log.error("JWT validation failed: {}", ex.getMessage());
            return unauthorized(exchange, ex.getMessage());
        }
        log.info("Token valid: {}", jwtService.isTokenValid(token));

        log.info("Name is {}", jwtService.extractName(token));
        log.info("Email is {}", jwtService.extractUsername(token));
        log.info("Phone is {}", jwtService.extractPhone(token));

        ServerHttpRequest request = exchange
                .getRequest()
                .mutate()
                .header("X-User-Id", String.valueOf(jwtService.extractUserId(token)))
                .header("X-User-Email", jwtService.extractUsername(token))
                .header("X-User-Role", jwtService.extractRole(token))
                .header("X-User-Name", jwtService.extractName(token))
                .header("X-User-Phone", jwtService.extractPhone(token))
                .build();


        return chain.filter(
                exchange.mutate()
                        .request(request)
                        .build()
        );
    }
    private Mono<Void> unauthorized(
            ServerWebExchange exchange,
            String message
    ) {
        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
        exchange.getResponse().getHeaders()
                .setContentType(MediaType.APPLICATION_JSON);

        String body = """
        {
          "status": 401,
          "error": "Unauthorized",
          "message": "%s"
        }
        """.formatted(message);

        DataBuffer buffer = exchange.getResponse()
                .bufferFactory()
                .wrap(body.getBytes(StandardCharsets.UTF_8));

        return exchange.getResponse().writeWith(Mono.just(buffer));
    }

    @Override
    public int getOrder() {
        return -1;
    }
}