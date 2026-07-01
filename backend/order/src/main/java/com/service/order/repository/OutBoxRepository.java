package com.service.order.repository;


import com.service.order.entity.OutBoxEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface OutBoxRepository extends JpaRepository<OutBoxEvent, UUID> {

    List<OutBoxEvent> findByPublishedFalse();
}
