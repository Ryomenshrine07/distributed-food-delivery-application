package com.service.delivery.service;

import com.service.delivery.entity.DeliveryAssignment;
import com.service.delivery.enums.DeliveryStatus;
import com.service.delivery.publisher.OutboxRecorder;
import com.service.delivery.repository.DeliveryAssignmentRepository;
import com.service.delivery.repository.DeliveryPartnerRepository;
import org.junit.jupiter.api.Test;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Random;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Property-based test for the idempotent rider release.
 *
 * <p><b>Feature: ui-modernization, Property 3: Idempotent rider release on completion</b>
 *
 * <p>For any assignment and any sequence of one or more {@code order-delivered} events for
 * that order, the delivery-service end state is assignment = {@code DELIVERED} and the partner
 * is released exactly once - processing the event again when the assignment is already
 * {@code DELIVERED} changes nothing further.
 *
 * <p><b>Validates: Requirements 3.3, 3.4</b>
 *
 * <p>Implemented as a deterministic, seeded generator loop over 200 iterations (>= the design's
 * 100-iteration minimum) with mocked repositories/collaborators. jqwik is not used because the
 * build must resolve offline and jqwik is not in the local repository; the seeded loop keeps the
 * property deterministic and reproducible (the seed and failing example are reported on failure).
 */
class DeliveryAssignmentServiceReleasePropertyTest {

    /** Minimum generated iterations mandated by the design's property-test configuration. */
    private static final int ITERATIONS = 200;

    private static final long SEED = 0x5EEDL;

    /** In-flight (releasable) states an assignment can be in when the customer confirms receipt. */
    private static final List<DeliveryStatus> PRE_COMPLETION_STATES =
            List.of(DeliveryStatus.ASSIGNED, DeliveryStatus.PICKED_UP);

    @Test
    void idempotentRiderReleaseOnCompletion() {
        final Random random = new Random(SEED);

        for (int i = 0; i < ITERATIONS; i++) {
            // --- generate a case -------------------------------------------------
            final DeliveryStatus initialStatus =
                    PRE_COMPLETION_STATES.get(random.nextInt(PRE_COMPLETION_STATES.size()));
            final int eventCount = 1 + random.nextInt(5); // replay the event 1..5 times
            final UUID orderId = UUID.randomUUID();
            final UUID partnerId = UUID.randomUUID();

            // Fresh mocks per iteration so the exactly-once verification is isolated.
            final DeliveryPartnerRepository partnerRepo = mock(DeliveryPartnerRepository.class);
            final DeliveryAssignmentRepository assignmentRepo = mock(DeliveryAssignmentRepository.class);
            final DeliveryPartnerService partnerService = mock(DeliveryPartnerService.class);
            final RedisLocationService redisLocationService = mock(RedisLocationService.class);
            final OutboxRecorder outboxRecorder = mock(OutboxRecorder.class);

            final DeliveryAssignment assignment = DeliveryAssignment.builder()
                    .id(UUID.randomUUID())
                    .orderId(orderId)
                    .customerId(UUID.randomUUID())
                    .restaurantId(UUID.randomUUID())
                    .deliveryPartnerId(partnerId)
                    .status(initialStatus)
                    .build();

            // The same managed entity is returned on every lookup, so once the first event
            // sets it to DELIVERED, later events see the already-DELIVERED state.
            when(assignmentRepo.findByOrderId(orderId)).thenReturn(Optional.of(assignment));

            final DeliveryAssignmentService service = new DeliveryAssignmentService(
                    partnerRepo,
                    assignmentRepo,
                    partnerService,
                    redisLocationService,
                    outboxRecorder
            );

            // --- act: replay the order-delivered event eventCount times ----------
            OffsetDateTime deliveredAtAfterFirst = null;
            for (int e = 0; e < eventCount; e++) {
                service.releaseForDeliveredOrder(orderId);
                if (e == 0) {
                    deliveredAtAfterFirst = assignment.getDeliveredAt();
                }
            }

            // --- assert the property --------------------------------------------
            try {
                assertEquals(DeliveryStatus.DELIVERED, assignment.getStatus(),
                        "assignment must end DELIVERED");
                assertNotNull(assignment.getDeliveredAt(), "deliveredAt must be set");
                assertEquals(deliveredAtAfterFirst, assignment.getDeliveredAt(),
                        "deliveredAt must not change on replay (no further mutation)");
                // The partner is released exactly once regardless of how many events arrive.
                verify(partnerService, times(1)).markAvailable(partnerId);
            } catch (AssertionError err) {
                throw new AssertionError(String.format(
                        "Property 3 failed at iteration %d of %d (seed=%d). "
                                + "Failing example: initialStatus=%s, eventCount=%d, "
                                + "orderId=%s, partnerId=%s.%n%s",
                        i, ITERATIONS, SEED, initialStatus, eventCount, orderId, partnerId,
                        err.getMessage()), err);
            }
        }
    }
}
