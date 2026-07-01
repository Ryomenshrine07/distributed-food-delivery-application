package com.service.apiGateway.filter;

import com.service.apiGateway.service.JwtService;
import io.jsonwebtoken.JwtException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.mock.http.server.reactive.MockServerHttpRequest;
import org.springframework.mock.web.server.MockServerWebExchange;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.util.UUID;
import java.util.concurrent.atomic.AtomicReference;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Unit tests for the gateway {@link JwtFilter}, focused on the scoped
 * WebSocket query-parameter auth fallback (Req 15.8).
 *
 * The critical invariant under test: the {@code ?token=} fallback applies ONLY
 * to {@code /ws/tracking/**}; every other route still requires the
 * {@code Authorization: Bearer} header, unchanged.
 */
class JwtFilterTest {

    private static final String GOOD = "good-token";
    private static final UUID USER_ID = UUID.fromString("00000000-0000-0000-0000-000000000001");

    private JwtService jwtService;
    private JwtFilter filter;
    private AtomicReference<ServerWebExchange> forwarded;
    private GatewayFilterChain chain;

    @BeforeEach
    void setUp() {
        jwtService = mock(JwtService.class);
        filter = new JwtFilter(jwtService);
        forwarded = new AtomicReference<>();
        chain = exchange -> {
            forwarded.set(exchange);
            return Mono.empty();
        };
    }

    /** Stub a fully valid token so injection can be asserted. */
    private void stubValidToken() {
        when(jwtService.isTokenValid(GOOD)).thenReturn(true);
        when(jwtService.extractUserId(GOOD)).thenReturn(USER_ID);
        when(jwtService.extractUsername(GOOD)).thenReturn("admin@example.com");
        when(jwtService.extractRole(GOOD)).thenReturn("ADMIN");
        when(jwtService.extractName(GOOD)).thenReturn("Admin User");
        when(jwtService.extractPhone(GOOD)).thenReturn("5551234");
    }

    private void assertInjectedHeaders(ServerHttpRequest req) {
        assertThat(req.getHeaders().getFirst("X-User-Id")).isEqualTo(USER_ID.toString());
        assertThat(req.getHeaders().getFirst("X-User-Email")).isEqualTo("admin@example.com");
        assertThat(req.getHeaders().getFirst("X-User-Role")).isEqualTo("ADMIN");
        assertThat(req.getHeaders().getFirst("X-User-Name")).isEqualTo("Admin User");
        assertThat(req.getHeaders().getFirst("X-User-Phone")).isEqualTo("5551234");
    }

    @Test
    void trackingRoute_withValidTokenQueryParam_passesAndInjectsHeaders() {
        stubValidToken();
        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/ws/tracking?token=" + GOOD));

        filter.filter(exchange, chain).block();

        assertThat(forwarded.get()).as("request should be forwarded").isNotNull();
        assertInjectedHeaders(forwarded.get().getRequest());
    }

    @Test
    void trackingRoute_withMissingToken_isUnauthorized() {
        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/ws/tracking"));

        filter.filter(exchange, chain).block();

        assertThat(forwarded.get()).as("request must not be forwarded").isNull();
        assertThat(exchange.getResponse().getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    void trackingRoute_withInvalidToken_isUnauthorized() {
        when(jwtService.isTokenValid("bad")).thenThrow(new JwtException("bad signature"));
        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/ws/tracking?token=bad"));

        filter.filter(exchange, chain).block();

        assertThat(forwarded.get()).isNull();
        assertThat(exchange.getResponse().getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    void trackingRoute_withValidBearerHeader_stillWorks() {
        stubValidToken();
        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/ws/tracking")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + GOOD));

        filter.filter(exchange, chain).block();

        assertThat(forwarded.get()).isNotNull();
        assertInjectedHeaders(forwarded.get().getRequest());
    }

    @Test
    void normalRoute_withoutHeader_isUnauthorized_evenWithTokenQueryParam() {
        // CRITICAL: the query-param fallback must NOT leak to other routes.
        stubValidToken();
        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/orders/admin?token=" + GOOD));

        filter.filter(exchange, chain).block();

        assertThat(forwarded.get()).as("non-tracking route must not accept ?token=").isNull();
        assertThat(exchange.getResponse().getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    void normalRoute_withValidBearerHeader_passesAndInjectsHeaders() {
        stubValidToken();
        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/orders/admin")
                        .header(HttpHeaders.AUTHORIZATION, "Bearer " + GOOD));

        filter.filter(exchange, chain).block();

        assertThat(forwarded.get()).isNotNull();
        assertInjectedHeaders(forwarded.get().getRequest());
    }

    @Test
    void lookalikeTrackingPath_withoutHeader_isUnauthorized() {
        // "/ws/tracking-other" must NOT be treated as the tracking route.
        stubValidToken();
        MockServerWebExchange exchange = MockServerWebExchange.from(
                MockServerHttpRequest.get("/ws/tracking-other?token=" + GOOD));

        filter.filter(exchange, chain).block();

        assertThat(forwarded.get()).isNull();
        assertThat(exchange.getResponse().getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }
}
