package com.service.auth.Repository;


import com.service.auth.Entities.OutBoxEvent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface OutBoxEventRepository extends JpaRepository<OutBoxEvent, UUID> {

    List<OutBoxEvent> getByPublishedFalse();
}
