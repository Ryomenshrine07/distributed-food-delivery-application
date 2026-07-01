package com.service.delivery.repository;

import com.service.delivery.entity.DeliveryPartner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface DeliveryPartnerRepository extends JpaRepository<DeliveryPartner, UUID> {

    /**
     * Fallback selection when Redis GEO has no nearby candidates (e.g. no live
     * location yet). Picks the longest-waiting available partner for fairness.
     */
    Optional<DeliveryPartner> findFirstByAvailableTrueOrderByCreatedAtAsc();

    Optional<DeliveryPartner> findFirstByAvailableTrueAndOnlineTrueOrderByCreatedAtAsc();

    /**
     * Filters the distance-sorted candidate ids returned by Redis GEO down to the
     * ones that are still available, so assignment decisions are made on fresh state.
     */
    List<DeliveryPartner> findByIdInAndAvailableTrue(Collection<UUID> ids);
}
