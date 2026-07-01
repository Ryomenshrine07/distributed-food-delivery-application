package com.service.delivery.consumer;

import com.service.delivery.client.AuthPartnerClient;
import com.service.delivery.controller.DeliveryAssignmentController;
import com.service.delivery.entity.DeliveryAssignment;
import com.service.delivery.entity.DeliveryPartner;
import com.service.delivery.enums.DeliveryStatus;
import com.service.delivery.event.OrderDeliveredEvent;
import com.service.delivery.publisher.OutboxRecorder;
import com.service.delivery.repository.DeliveryAssignmentRepository;
import com.service.delivery.repository.DeliveryPartnerRepository;
import com.service.delivery.service.DeliveryAssignmentService;
import com.service.delivery.service.DeliveryPartnerService;
import com.service.delivery.service.RedisLocationService;
import org.junit.jupiter.api.Test;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.lang.reflect.Method;
import java.time.OffsetDateTime;
import java.util.Arrays;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Behavioral tests for the customer-only completion guard (Item 3, guarantees G1-G3).
 *
 * <ul>
 *   <li><b>G1 (customer-only completion):</b> the rider self-completion surface is gone - the
 *       delivery service has no {@code completeDelivery} method and the controller no longer
 *       exposes a {@code /delivered} endpoint, so no rider action can transition an order to
 *       {@code DELIVERED}. (Requirements 3.8, 3.9)</li>
 *   <li><b>G2 (rider release preserved):</b> the customer-driven {@code order-delivered} event,
 *       consumed by {@link OrderDeliveredConsumer}, sets the assignment to {@code DELIVERED} and
 *       frees the assigned partner. (Requirements 3.1, 3.2, 3.5)</li>
 *   <li><b>G3 (no stranded rider):</b> after the consumer runs, the partner is available again
 *       (and released exactly once even if the event is redelivered). (Requirement 3.5)</li>
 * </ul>
 */
class OrderDeliveredReleaseBehavioralTest {

    private DeliveryPartner partner(UUID partnerId, UUID assignmentId) {
        DeliveryPartner partner = DeliveryPartner.builder()
                .id(partnerId)
                .name("Rider Ravi")
                .phone("+15551234567")
                .available(false)
                .online(true)
                .currentAssignmentId(assignmentId)
                .build();
        return partner;
    }

    private DeliveryAssignment assignment(UUID orderId, UUID partnerId, UUID assignmentId) {
        return DeliveryAssignment.builder()
                .id(assignmentId)
                .orderId(orderId)
                .customerId(UUID.randomUUID())
                .restaurantId(UUID.randomUUID())
                .deliveryPartnerId(partnerId)
                .status(DeliveryStatus.PICKED_UP)
                .build();
    }

    /**
     * G2 + G3: the customer confirmation (order-delivered) drives the consumer to complete the
     * assignment and free the rider end-to-end within the delivery domain.
     */
    @Test
    void consumerDrivenReleaseFreesTheRider() {
        UUID orderId = UUID.randomUUID();
        UUID partnerId = UUID.randomUUID();
        UUID assignmentId = UUID.randomUUID();

        DeliveryPartnerRepository partnerRepo = mock(DeliveryPartnerRepository.class);
        DeliveryAssignmentRepository assignmentRepo = mock(DeliveryAssignmentRepository.class);
        RedisLocationService redis = mock(RedisLocationService.class);
        OutboxRecorder outbox = mock(OutboxRecorder.class);
        AuthPartnerClient authClient = mock(AuthPartnerClient.class);
        @SuppressWarnings("unchecked")
        KafkaTemplate<String, Object> kafka = mock(KafkaTemplate.class);

        DeliveryPartner partner = partner(partnerId, assignmentId);
        DeliveryAssignment assignment = assignment(orderId, partnerId, assignmentId);

        when(assignmentRepo.findByOrderId(orderId)).thenReturn(Optional.of(assignment));
        when(partnerRepo.findById(partnerId)).thenReturn(Optional.of(partner));

        // Real collaborating services, mocked repositories - exercises the true release path.
        DeliveryPartnerService partnerService =
                new DeliveryPartnerService(partnerRepo, assignmentRepo, redis, authClient, kafka);
        DeliveryAssignmentService assignmentService =
                new DeliveryAssignmentService(partnerRepo, assignmentRepo, partnerService, redis, outbox);
        OrderDeliveredConsumer consumer = new OrderDeliveredConsumer(assignmentService);

        consumer.consume(new OrderDeliveredEvent(orderId, partnerId, OffsetDateTime.now()));

        // G2: the assignment is completed.
        assertEquals(DeliveryStatus.DELIVERED, assignment.getStatus(),
                "assignment should be DELIVERED after the customer confirmation");
        assertNotNull(assignment.getDeliveredAt(), "deliveredAt should be stamped");

        // G3: the rider is freed - available again with no lingering assignment.
        assertTrue(partner.isAvailable(), "partner should be available again (no stranded rider)");
        assertNull(partner.getCurrentAssignmentId(), "partner's current assignment should be cleared");
        verify(partnerRepo, times(1)).save(partner);
    }

    /**
     * G3 idempotency: replaying the same order-delivered event does not release the rider twice
     * and leaves the delivered assignment/partner untouched.
     */
    @Test
    void redeliveredEventReleasesRiderExactlyOnce() {
        UUID orderId = UUID.randomUUID();
        UUID partnerId = UUID.randomUUID();
        UUID assignmentId = UUID.randomUUID();

        DeliveryPartnerRepository partnerRepo = mock(DeliveryPartnerRepository.class);
        DeliveryAssignmentRepository assignmentRepo = mock(DeliveryAssignmentRepository.class);
        RedisLocationService redis = mock(RedisLocationService.class);
        OutboxRecorder outbox = mock(OutboxRecorder.class);
        AuthPartnerClient authClient = mock(AuthPartnerClient.class);
        @SuppressWarnings("unchecked")
        KafkaTemplate<String, Object> kafka = mock(KafkaTemplate.class);

        DeliveryPartner partner = partner(partnerId, assignmentId);
        DeliveryAssignment assignment = assignment(orderId, partnerId, assignmentId);

        when(assignmentRepo.findByOrderId(orderId)).thenReturn(Optional.of(assignment));
        when(partnerRepo.findById(partnerId)).thenReturn(Optional.of(partner));

        DeliveryPartnerService partnerService =
                new DeliveryPartnerService(partnerRepo, assignmentRepo, redis, authClient, kafka);
        DeliveryAssignmentService assignmentService =
                new DeliveryAssignmentService(partnerRepo, assignmentRepo, partnerService, redis, outbox);
        OrderDeliveredConsumer consumer = new OrderDeliveredConsumer(assignmentService);

        OrderDeliveredEvent event = new OrderDeliveredEvent(orderId, partnerId, OffsetDateTime.now());
        consumer.consume(event);
        OffsetDateTime deliveredAt = assignment.getDeliveredAt();
        consumer.consume(event); // replay
        consumer.consume(event); // replay again

        assertEquals(DeliveryStatus.DELIVERED, assignment.getStatus());
        assertEquals(deliveredAt, assignment.getDeliveredAt(), "deliveredAt must not change on replay");
        assertTrue(partner.isAvailable());
        // markAvailable -> save happens only for the first (state-changing) event.
        verify(partnerRepo, times(1)).save(partner);
    }

    /**
     * G1: the rider self-completion surface has been removed. The delivery service must expose no
     * {@code completeDelivery} operation, so completion can only happen via the customer path.
     */
    @Test
    void deliveryServiceHasNoRiderSelfCompletionMethod() {
        boolean hasCompleteDelivery = Arrays.stream(DeliveryAssignmentService.class.getDeclaredMethods())
                .anyMatch(m -> m.getName().equals("completeDelivery"));
        assertFalse(hasCompleteDelivery,
                "DeliveryAssignmentService.completeDelivery must be removed (completion is customer-only)");
    }

    /**
     * G1: the rider-facing controller must no longer expose the {@code /delivered} self-completion
     * endpoint (neither a {@code markDelivered} handler nor any mapping whose path contains
     * "delivered").
     */
    @Test
    void controllerExposesNoDeliveredEndpoint() {
        Method[] methods = DeliveryAssignmentController.class.getDeclaredMethods();

        boolean hasMarkDelivered = Arrays.stream(methods)
                .anyMatch(m -> m.getName().equals("markDelivered"));
        assertFalse(hasMarkDelivered, "controller markDelivered handler must be removed");

        for (Method method : methods) {
            PostMapping post = method.getAnnotation(PostMapping.class);
            if (post != null) {
                assertTrue(Arrays.stream(post.value()).noneMatch(p -> p.contains("delivered"))
                                && Arrays.stream(post.path()).noneMatch(p -> p.contains("delivered")),
                        "no @PostMapping may route to a /delivered path: " + method.getName());
            }
            RequestMapping req = method.getAnnotation(RequestMapping.class);
            if (req != null) {
                assertTrue(Arrays.stream(req.value()).noneMatch(p -> p.contains("delivered"))
                                && Arrays.stream(req.path()).noneMatch(p -> p.contains("delivered")),
                        "no @RequestMapping may route to a /delivered path: " + method.getName());
            }
        }
    }
}
