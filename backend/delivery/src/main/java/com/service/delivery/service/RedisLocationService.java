package com.service.delivery.service;


import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.geo.Circle;
import org.springframework.data.geo.Distance;
import org.springframework.data.geo.GeoResults;
import org.springframework.data.geo.Metrics;
import org.springframework.data.geo.Point;
import org.springframework.data.redis.connection.RedisGeoCommands;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

/**
 * Owns the live, fast-changing geo location of delivery partners.
 *
 * <p>Location is intentionally kept in Redis GEO rather than PostgreSQL: it changes on
 * every GPS ping, is read on the hot path of order assignment, and is disposable
 * (a partner who stops sending heartbeats should simply fall out of the search).
 * This keeps the relational store for durable operational state only.
 *
 * <p>Redis GEO stores coordinates as a {@link Point} of (longitude, latitude) - note the
 * order - so both writes and reads here use that ordering consistently.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RedisLocationService {

    private static final String DELIVERY_LOCATION_KEY = "delivery:locations";

    private final StringRedisTemplate redisTemplate;

    /** Upsert the partner's current position in the geo index. */
    public void updateLocation(
            UUID partnerId,
            double latitude,
            double longitude
    ) {
        redisTemplate.opsForGeo()
                .add(
                        DELIVERY_LOCATION_KEY,
                        new Point(longitude, latitude),
                        partnerId.toString()
                );
    }

    /** Drop the partner from the geo index (e.g. when they go offline). */
    public void removeLocation(UUID partnerId) {
        redisTemplate.opsForGeo()
                .remove(DELIVERY_LOCATION_KEY, partnerId.toString());
    }

    /**
     * Returns partner ids within {@code radiusKm} of the given point, nearest first.
     *
     * <p>This is the "nearby rider search" used by the assignment flow. It only returns
     * proximity - the caller is responsible for filtering to partners that are still
     * available, because availability is durable state owned by the relational store.
     */
    public List<UUID> findNearbyPartners(
            double latitude,
            double longitude,
            double radiusKm,
            int limit
    ) {
        Circle searchArea = new Circle(
                new Point(longitude, latitude),
                new Distance(radiusKm, Metrics.KILOMETERS)
        );

        RedisGeoCommands.GeoRadiusCommandArgs args =
                RedisGeoCommands.GeoRadiusCommandArgs.newGeoRadiusArgs()
                        .includeDistance()
                        .sortAscending()
                        .limit(limit);

        GeoResults<RedisGeoCommands.GeoLocation<String>> results =
                redisTemplate.opsForGeo().radius(DELIVERY_LOCATION_KEY, searchArea, args);

        if (results == null) {
            return List.of();
        }

        return results.getContent()
                .stream()
                .map(result -> result.getContent().getName())
                .map(UUID::fromString)
                .toList();
    }

    /** Returns the partner's current location from the geo index. */
    public Point getPartnerLocation(UUID partnerId) {
        List<Point> positions = redisTemplate.opsForGeo().position(DELIVERY_LOCATION_KEY, partnerId.toString());
        if (positions == null || positions.isEmpty()) {
            return null;
        }
        return positions.get(0);
    }
}
