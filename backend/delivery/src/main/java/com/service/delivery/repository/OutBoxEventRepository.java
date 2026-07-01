package com.service.delivery.repository;


import com.service.delivery.entity.OutBoxEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface OutBoxEventRepository extends JpaRepository<OutBoxEvent, UUID> {

    List<OutBoxEvent> findByPublishedFalse();

}
