package com.service.restaurant.repository;


import com.service.restaurant.entity.Restaurant;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

@Repository
public interface RestaurantRepository  extends JpaRepository<Restaurant, UUID> {

    boolean existsByOwnerIdAndNameIgnoreCaseAndDeletedFalse(UUID ownerId, String name);

    boolean existsByOwnerIdAndNameIgnoreCaseAndDeletedFalseAndIdNot(UUID ownerId, String name, UUID id);

    Optional<Restaurant> findByIdAndActiveTrueAndDeletedFalse(UUID id);

    Optional<Restaurant> findByIdAndDeletedFalse(UUID id);

    Page<Restaurant> findByActiveTrueAndDeletedFalse(Pageable pageable);

    Page<Restaurant> findByCityIgnoreCaseAndActiveTrueAndDeletedFalse(String city, Pageable pageable);

    @Query("""
            select distinct r from Restaurant r
            left join r.categories c
            where r.active = true and r.deleted = false
              and lower(c.name) = lower(:category)
            """)
    Page<Restaurant> findCustomerRestaurantsByCategory(@Param("category") String category, Pageable pageable);

    @Query("""
            select distinct r from Restaurant r
            left join r.categories c
            left join c.items i
            where r.active = true and r.deleted = false
              and (lower(r.name) like lower(concat('%', :keyword, '%'))
                or lower(coalesce(r.cuisine, '')) like lower(concat('%', :keyword, '%'))
                or lower(i.name) like lower(concat('%', :keyword, '%')))
            """)
    Page<Restaurant> searchCustomerRestaurants(@Param("keyword") String keyword, Pageable pageable);
}
