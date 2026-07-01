package com.service.restaurant.repository;


import com.service.restaurant.entity.MenuItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface MenuItemRepository extends JpaRepository<MenuItem, UUID> {

    List<MenuItem> findByCategoryId(UUID categoryId);

    boolean existsByCategoryIdAndNameIgnoreCase(UUID categoryId, String name);

    @Query("""
    SELECT mi
    FROM MenuItem mi
    JOIN FETCH mi.category c
    JOIN FETCH c.restaurant r
    WHERE mi.id = :id
""")
    Optional<MenuItem> findDetailsById(UUID id);
}
