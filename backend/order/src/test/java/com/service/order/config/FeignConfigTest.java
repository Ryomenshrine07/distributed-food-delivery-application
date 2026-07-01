package com.service.order.config;

import feign.RequestInterceptor;
import feign.RequestTemplate;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import static org.assertj.core.api.Assertions.assertThat;

class FeignConfigTest {

    @AfterEach
    void clearRequestContext() {
        RequestContextHolder.resetRequestAttributes();
    }

    @Test
    void forwardsGatewayUserHeadersToRestaurantService() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("X-User-Id", "3f349df9-fc33-4a26-98c8-01945d7c1ec4");
        request.addHeader("X-User-Email", "customer@example.com");
        request.addHeader("X-User-Role", "CUSTOMER");
        request.addHeader("Authorization", "Bearer token");
        RequestContextHolder.setRequestAttributes(new ServletRequestAttributes(request));

        RequestInterceptor interceptor = new FeignConfig().requestInterceptor();
        RequestTemplate template = new RequestTemplate();

        interceptor.apply(template);

        assertThat(template.headers().get("X-User-Id"))
                .containsExactly("3f349df9-fc33-4a26-98c8-01945d7c1ec4");
        assertThat(template.headers().get("X-User-Email"))
                .containsExactly("customer@example.com");
        assertThat(template.headers().get("X-User-Role"))
                .containsExactly("CUSTOMER");
        assertThat(template.headers()).doesNotContainKey("Authorization");
    }
}
