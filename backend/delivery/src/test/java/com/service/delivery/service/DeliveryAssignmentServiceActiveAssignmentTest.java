package com.service.delivery.service;

import com.service.delivery.entity.DeliveryAssignment;
import com.service.delivery.enums.DeliveryStatus;
import com.service.delivery.publisher.OutboxRecorder;
import com.service.delivery.repository.DeliveryAssignmentRepository;
import com.service.delivery.repository.DeliveryPartnerRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.time.OffsetDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

/**
 * Unit tests for the read-only recovery lookup {@link DeliveryAssignmentService#getActiveAssignmentForPartner}.
 *
 * <p>Backs {@code GET /api/delivery/assignments/current}, which lets the rider's app restore an
 * in-progress delivery after a reinstall wiped its local cache. The service must return the
 * partner's active ({@code ASSIGNED}/{@code PICKED_UP}) assignment when the repository finds one,
 * and {@code null} when it does not. Repositories/collaborators are mocked so the test resolves
 * offline (JUnit + Mockito), matching the existing delivery test style.
 */
class DeliveryAssignmentServiceActiveAssignmentTest {

    private DeliveryAssignmentRepository assignmentRepo;
    private DeliveryAssignmentService service;

    @BeforeEach
    void setUp() {
        DeliveryPartnerRepository partnerRepo = mock(DeliveryPartnerRepository.class);
        assignmentRepo = mock(DeliveryAssignmentRepository.class);
        DeliveryPartnerService partnerService = mock(DeliveryPartnerService.class);
        RedisLocationService redisLocationService = mock(RedisLocationService.class);
        OutboxRecorder outboxRecorder = mock(OutboxRecorder.class);

        service = new DeliveryAssignmentService(
                partnerRepo,
                assignmentRepo,
                partnerService,
                redisLocationService,
                outboxRecorder
        );
    }

    @Test
    void returnsTheActiveAssignmentWhenTheRepositoryFindsOne() {
        UUID partnerId = UUID.randomUUID();
        DeliveryAssignment assignment = DeliveryAssignment.builder()
                .id(UUID.randomUUID())
                .orderId(UUID.randomUUID())
                .customerId(UUID.randomUUID())
                .restaurantId(UUID.randomUUID())
                .deliveryPartnerId(partnerId)
                .status(DeliveryStatus.ASSIGNED)
                .assignedAt(OffsetDateTime.now())
                .build();

        when(assignmentRepo.findFirstByDeliveryPartnerIdAndStatusInOrderByAssignedAtDesc(
                eq(partnerId), anyList()))
                .thenReturn(Optional.of(assignment));

        DeliveryAssignment result = service.getActiveAssignmentForPartner(partnerId);

        assertSame(assignment, result, "should return the assignment the repository found");

        // The lookup must ask for exactly the active/unfinished states (ASSIGNED, PICKED_UP) so
        // nothing stale is recovered and only Dart-parsable statuses are ever returned.
        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<DeliveryStatus>> statusesCaptor = ArgumentCaptor.forClass(List.class);
        verify(assignmentRepo).findFirstByDeliveryPartnerIdAndStatusInOrderByAssignedAtDesc(
                eq(partnerId), statusesCaptor.capture());
        assertEquals(
                List.of(DeliveryStatus.ASSIGNED, DeliveryStatus.PICKED_UP),
                statusesCaptor.getValue(),
                "recovery must query only the ASSIGNED and PICKED_UP states");
    }

    @Test
    void returnsNullWhenTheRepositoryFindsNoActiveAssignment() {
        UUID partnerId = UUID.randomUUID();

        when(assignmentRepo.findFirstByDeliveryPartnerIdAndStatusInOrderByAssignedAtDesc(
                eq(partnerId), anyList()))
                .thenReturn(Optional.empty());

        DeliveryAssignment result = service.getActiveAssignmentForPartner(partnerId);

        assertNull(result, "no active assignment → null (controller maps this to 204 No Content)");
    }
}
