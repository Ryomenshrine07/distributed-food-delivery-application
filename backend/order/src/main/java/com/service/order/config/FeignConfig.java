package com.service.order.config;

import feign.RequestInterceptor;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@Configuration
public class FeignConfig {

    @Bean
    public RequestInterceptor requestInterceptor() {

        return template -> {

            ServletRequestAttributes attributes =
                    (ServletRequestAttributes)
                            RequestContextHolder.getRequestAttributes();

            if (attributes == null) {
                return;
            }

            HttpServletRequest request = attributes.getRequest();

            copyHeader(request, template, "X-User-Id");
            copyHeader(request, template, "X-User-Email");
            copyHeader(request, template, "X-User-Role");
            copyHeader(request, template, "X-User-Phone");
            copyHeader(request, template, "X-User-Name");
        };
    }

    private void copyHeader(
            HttpServletRequest request,
            feign.RequestTemplate template,
            String headerName
    ) {
        String value = request.getHeader(headerName);

        if (value != null && !value.isBlank()) {
            template.header(headerName, value);
        }
    }
}