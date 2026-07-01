/**
 * Pure helpers for the admin live rider map (Req 15.2, 15.4).
 *
 * These functions are deliberately free of React, STOMP, and Leaflet so they
 * can be exercised directly by the Property tests (Properties 8 and 10).
 */

/**
 * A single rider location broadcast on `/topic/admin/riders/location`.
 *
 * Mirrors the backend `tracking` service record
 * (`com.service.tracking.dto.RiderLocationUpdate`): `riderId`/`orderId` are
 * UUIDs serialized as strings (`orderId` is null when the rider is online but
 * unassigned) and `timestamp` is epoch millis.
 */
export interface RiderLocationUpdate {
  riderId: string;
  orderId: string | null;
  latitude: number;
  longitude: number;
  timestamp: number;
}

/**
 * Derive the STOMP-over-WebSocket URL for the tracking handshake from the REST
 * API base URL (Req 15.2).
 *
 * The rules (validated by Property 10):
 *   - scheme is `wss:` when the base is `https:`, and `ws:` otherwise,
 *   - host and port are preserved exactly,
 *   - the path is always `/ws/tracking`,
 *   - any query string / hash on the base is dropped.
 *
 * The admin JWT is appended by the caller (the gateway reads it from the
 * `?token=` query parameter for this route); this function never emits a query.
 */
export function deriveTrackingWsUrl(apiBaseUrl: string): string {
  const base = new URL(apiBaseUrl);
  const wsProtocol = base.protocol === 'https:' ? 'wss:' : 'ws:';
  // `host` includes the port when one is present, so host+port is preserved.
  return `${wsProtocol}//${base.host}/ws/tracking`;
}

/**
 * Fold a rider location update into the current marker map (Req 15.4).
 *
 * Markers are keyed by `riderId`; the update with the greatest `timestamp`
 * wins. Ties use `>=`, so a later update with an equal timestamp replaces the
 * earlier one. Returns a NEW Map and never mutates its inputs, so it is safe to
 * drive React state.
 */
export function upsertRiders(
  current: Map<string, RiderLocationUpdate>,
  update: RiderLocationUpdate,
): Map<string, RiderLocationUpdate> {
  const next = new Map(current);
  const existing = next.get(update.riderId);
  if (!existing || update.timestamp >= existing.timestamp) {
    next.set(update.riderId, update);
  }
  return next;
}
