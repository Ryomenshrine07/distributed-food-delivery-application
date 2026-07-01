import { useEffect, useState } from 'react';
import { Client, type IFrame, type IMessage, type StompConfig } from '@stomp/stompjs';
import { useSessionStore } from '@/store/session';
import {
  deriveTrackingWsUrl,
  upsertRiders,
  type RiderLocationUpdate,
} from '@/lib/tracking-url';

/** STOMP topic the tracking service broadcasts every rider location on. */
export const TRACKING_TOPIC = '/topic/admin/riders/location';

const DEFAULT_API_URL = 'http://localhost:8080';

/** Default STOMP auto-reconnect backoff (ms). Passed through as `reconnectDelay`. */
export const DEFAULT_RECONNECT_DELAY_MS = 5000;

export type TrackingConnectionState = 'idle' | 'connecting' | 'connected' | 'error';

export interface TrackingSnapshot {
  connectionState: TrackingConnectionState;
  /** Latest known location per rider, keyed by `riderId`. */
  riders: Map<string, RiderLocationUpdate>;
  /** Human-readable error surfaced in the non-blocking connection banner. */
  lastError: string | null;
  /** Epoch millis of the most recent frame received (drives "last seen"). */
  lastEventAt: number | null;
}

type TrackingListener = (snapshot: TrackingSnapshot) => void;

/**
 * The minimal slice of `@stomp/stompjs`'s `Client` the service depends on.
 * Declaring it structurally lets tests inject a fake client that feeds frames
 * and drives the lifecycle callbacks without a real socket.
 */
export interface StompClientLike {
  activate(): void;
  deactivate(): Promise<void> | void;
  subscribe(
    destination: string,
    callback: (message: IMessage) => void,
  ): { unsubscribe(): void };
}

export type StompClientFactory = (config: StompConfig) => StompClientLike;

export interface TrackingClientOptions {
  /** REST API base URL; the ws URL is derived from it. Defaults to `VITE_API_URL`. */
  apiBaseUrl?: string;
  /** Supplies the admin JWT. Defaults to the persisted session token. */
  getToken?: () => string | null | undefined;
  /** Injects the STOMP client (tests pass a fake); defaults to a real `Client`. */
  clientFactory?: StompClientFactory;
  /** Auto-reconnect backoff in ms. */
  reconnectDelayMs?: number;
}

/**
 * Parse a raw STOMP frame body into a `RiderLocationUpdate`, returning `null`
 * for anything malformed so a bad frame can never crash the live map.
 */
export function parseRiderLocationUpdate(body: string): RiderLocationUpdate | null {
  let raw: unknown;
  try {
    raw = JSON.parse(body);
  } catch {
    return null;
  }
  if (typeof raw !== 'object' || raw === null) return null;
  const r = raw as Record<string, unknown>;
  if (
    typeof r.riderId === 'string' &&
    typeof r.latitude === 'number' &&
    typeof r.longitude === 'number' &&
    typeof r.timestamp === 'number'
  ) {
    return {
      riderId: r.riderId,
      orderId: typeof r.orderId === 'string' ? r.orderId : null,
      latitude: r.latitude,
      longitude: r.longitude,
      timestamp: r.timestamp,
    };
  }
  return null;
}

function stompErrorMessage(frame: IFrame | undefined): string {
  const message = frame?.headers?.['message'];
  return message ? `Live tracking error: ${message}` : 'Live tracking connection error';
}

const DISCONNECTED_MESSAGE = 'Live tracking disconnected. Reconnecting…';

/**
 * Manages a single STOMP subscription to the rider-location topic (Req 15.3,
 * 15.4, 15.6, 15.9).
 *
 * It is transport-agnostic (via `clientFactory`) and exposes an observable
 * snapshot so React can render connection state, the rider markers, and the
 * last-seen indicator. Reconnection is delegated to the STOMP client's
 * `reconnectDelay`; connection loss is surfaced as a non-blocking error.
 */
export class TrackingClient {
  private readonly apiBaseUrl: string;
  private readonly getToken: () => string | null | undefined;
  private readonly clientFactory: StompClientFactory;
  private readonly reconnectDelayMs: number;

  private client: StompClientLike | null = null;
  private subscription: { unsubscribe(): void } | null = null;
  private active = false;
  private readonly listeners = new Set<TrackingListener>();
  private riders: Map<string, RiderLocationUpdate> = new Map();
  private snapshot: TrackingSnapshot;

  constructor(options: TrackingClientOptions = {}) {
    this.apiBaseUrl =
      options.apiBaseUrl ?? (import.meta.env.VITE_API_URL || DEFAULT_API_URL);
    this.getToken =
      options.getToken ?? (() => useSessionStore.getState().session?.token);
    this.clientFactory = options.clientFactory ?? ((config) => new Client(config));
    this.reconnectDelayMs = options.reconnectDelayMs ?? DEFAULT_RECONNECT_DELAY_MS;
    this.snapshot = {
      connectionState: 'idle',
      riders: this.riders,
      lastError: null,
      lastEventAt: null,
    };
  }

  getSnapshot(): TrackingSnapshot {
    return this.snapshot;
  }

  /** Register a listener; immediately receives the current snapshot. */
  subscribe(listener: TrackingListener): () => void {
    this.listeners.add(listener);
    listener(this.snapshot);
    return () => {
      this.listeners.delete(listener);
    };
  }

  private emit(patch: Partial<TrackingSnapshot>): void {
    this.snapshot = { ...this.snapshot, ...patch };
    for (const listener of this.listeners) listener(this.snapshot);
  }

  /** Open the connection. Safe to call once per lifecycle. */
  start(): void {
    if (this.client) return;
    this.active = true;
    const token = this.getToken() ?? '';
    // The gateway reads the JWT from `?token=` for the /ws/tracking route
    // (a browser cannot set the Authorization header on a WS handshake).
    const brokerURL = `${deriveTrackingWsUrl(this.apiBaseUrl)}?token=${encodeURIComponent(token)}`;
    this.emit({ connectionState: 'connecting' });
    this.client = this.clientFactory({
      brokerURL,
      reconnectDelay: this.reconnectDelayMs,
      onConnect: () => this.handleConnect(),
      onStompError: (frame) => this.handleError(stompErrorMessage(frame)),
      onWebSocketError: () => this.handleError('Live tracking connection error'),
      onWebSocketClose: () => this.handleClose(),
    });
    this.client.activate();
  }

  /** Tear down the connection and stop emitting. */
  stop(): void {
    this.active = false;
    try {
      this.subscription?.unsubscribe();
    } catch {
      // ignore teardown errors
    }
    this.subscription = null;
    void this.client?.deactivate();
    this.client = null;
  }

  private handleConnect(): void {
    if (!this.client || !this.active) return;
    this.subscription = this.client.subscribe(TRACKING_TOPIC, (message) =>
      this.handleFrame(message.body),
    );
    this.emit({ connectionState: 'connected', lastError: null });
  }

  private handleFrame(body: string): void {
    const update = parseRiderLocationUpdate(body);
    if (!update) return; // ignore malformed frames; keep the map running
    this.riders = upsertRiders(this.riders, update);
    this.emit({ riders: this.riders, lastEventAt: Date.now() });
  }

  private handleError(message: string): void {
    if (!this.active) return;
    this.emit({ connectionState: 'error', lastError: message });
  }

  private handleClose(): void {
    if (!this.active) return;
    // A dropped or unauthorized socket surfaces a non-blocking error while the
    // STOMP client keeps retrying via reconnectDelay (Req 15.9).
    this.emit({
      connectionState: 'error',
      lastError: this.snapshot.lastError ?? DISCONNECTED_MESSAGE,
    });
  }
}

/**
 * React hook that owns a `TrackingClient` for the lifetime of the component and
 * re-renders on every snapshot change. Options are captured once on mount.
 */
export function useRiderTracking(options?: TrackingClientOptions): TrackingSnapshot {
  const [client] = useState(() => new TrackingClient(options ?? {}));
  const [snapshot, setSnapshot] = useState<TrackingSnapshot>(() => client.getSnapshot());

  useEffect(() => {
    const unsubscribe = client.subscribe(setSnapshot);
    client.start();
    return () => {
      unsubscribe();
      client.stop();
    };
  }, [client]);

  return snapshot;
}
