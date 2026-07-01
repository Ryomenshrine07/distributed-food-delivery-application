import { render, screen, act } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import { LiveMap } from '@/pages/LiveMap';
import { TRACKING_TOPIC, type StompClientFactory } from '@/services/tracking';

// Leaflet touches the real DOM/canvas; mock react-leaflet with lightweight DOM
// so the page renders in jsdom while still exposing markers/positions to assert.
vi.mock('react-leaflet', () => ({
  MapContainer: ({ children }: { children?: React.ReactNode }) => (
    <div data-testid="map">{children}</div>
  ),
  TileLayer: ({ url }: { url: string }) => <div data-testid="tile-layer" data-url={url} />,
  Marker: ({
    children,
    position,
  }: {
    children?: React.ReactNode;
    position: [number, number];
  }) => (
    <div data-testid="rider-marker" data-position={JSON.stringify(position)}>
      {children}
    </div>
  ),
  Popup: ({ children }: { children?: React.ReactNode }) => <div>{children}</div>,
}));

vi.mock('leaflet', () => ({
  default: { divIcon: (opts: unknown) => ({ options: opts }) },
}));

/** A fake STOMP client that lets the test drive lifecycle + feed frames. */
function createFakeStomp() {
  let config: import('@stomp/stompjs').StompConfig | null = null;
  const subs = new Map<string, (message: { body: string }) => void>();
  const state = { activated: false, deactivated: false };

  const factory: StompClientFactory = (cfg) => {
    config = cfg;
    return {
      activate() {
        state.activated = true;
      },
      deactivate() {
        state.deactivated = true;
      },
      subscribe(destination, callback) {
        subs.set(destination, callback as unknown as (m: { body: string }) => void);
        return {
          unsubscribe() {
            subs.delete(destination);
          },
        };
      },
    };
  };

  const invoke = (cb: ((arg: never) => void) | undefined) => cb?.(undefined as never);

  return {
    factory,
    get brokerURL() {
      return config?.brokerURL;
    },
    get activated() {
      return state.activated;
    },
    get deactivated() {
      return state.deactivated;
    },
    connect: () => act(() => invoke(config?.onConnect)),
    frame: (payload: unknown) =>
      act(() => subs.get(TRACKING_TOPIC)?.({ body: JSON.stringify(payload) })),
    dropSocket: () => act(() => invoke(config?.onWebSocketClose)),
    errorSocket: () => act(() => invoke(config?.onWebSocketError)),
  };
}

const rider = (over: Partial<Record<string, unknown>> = {}) => ({
  riderId: 'r1',
  orderId: null,
  latitude: 12.9,
  longitude: 77.6,
  timestamp: 1000,
  ...over,
});

describe('LiveMap page — STOMP subscription, upsert, and error state', () => {
  it('derives the ws URL with the JWT and activates the client on mount', () => {
    const fake = createFakeStomp();
    render(
      <LiveMap
        trackingOptions={{
          clientFactory: fake.factory,
          apiBaseUrl: 'http://localhost:8080',
          getToken: () => 'test-jwt',
        }}
      />,
    );

    expect(fake.activated).toBe(true);
    expect(fake.brokerURL).toBe('ws://localhost:8080/ws/tracking?token=test-jwt');
    // Before connecting: a non-blocking "connecting" status, zero riders (Req 15.5).
    expect(screen.getByRole('status')).toHaveTextContent(/connecting/i);
    expect(screen.getByTestId('rider-count')).toHaveTextContent('Active riders: 0');
    expect(screen.getByTestId('last-seen')).toHaveTextContent(/waiting for updates/i);
  });

  it('renders one marker per rider and moves it on newer frames (Req 15.3, 15.4)', () => {
    const fake = createFakeStomp();
    render(
      <LiveMap
        trackingOptions={{ clientFactory: fake.factory, apiBaseUrl: 'http://localhost:8080', getToken: () => 'jwt' }}
      />,
    );

    fake.connect();
    expect(screen.getByTestId('connection-status')).toHaveTextContent('Live');

    // First frame for r1 -> one marker, count 1, last-seen updates (Req 15.5).
    fake.frame(rider({ riderId: 'r1', latitude: 12.9, longitude: 77.6, timestamp: 1000 }));
    let markers = screen.getAllByTestId('rider-marker');
    expect(markers).toHaveLength(1);
    expect(markers[0]).toHaveAttribute('data-position', JSON.stringify([12.9, 77.6]));
    expect(screen.getByTestId('rider-count')).toHaveTextContent('Active riders: 1');
    expect(screen.getByTestId('last-seen')).toHaveTextContent(/last update/i);

    // Newer frame for r1 -> still one marker, moved to the new position (Req 15.4).
    fake.frame(rider({ riderId: 'r1', latitude: 13.5, longitude: 78.1, timestamp: 2000 }));
    markers = screen.getAllByTestId('rider-marker');
    expect(markers).toHaveLength(1);
    expect(markers[0]).toHaveAttribute('data-position', JSON.stringify([13.5, 78.1]));

    // A second rider -> two markers, count 2.
    fake.frame(rider({ riderId: 'r2', latitude: 19.1, longitude: 72.9, timestamp: 1500 }));
    expect(screen.getAllByTestId('rider-marker')).toHaveLength(2);
    expect(screen.getByTestId('rider-count')).toHaveTextContent('Active riders: 2');
  });

  it('ignores a stale (older-timestamp) frame for a known rider (Req 15.4)', () => {
    const fake = createFakeStomp();
    render(
      <LiveMap
        trackingOptions={{ clientFactory: fake.factory, apiBaseUrl: 'http://localhost:8080', getToken: () => 'jwt' }}
      />,
    );
    fake.connect();

    fake.frame(rider({ riderId: 'r1', latitude: 13.5, longitude: 78.1, timestamp: 2000 }));
    fake.frame(rider({ riderId: 'r1', latitude: 1.0, longitude: 1.0, timestamp: 500 }));

    const markers = screen.getAllByTestId('rider-marker');
    expect(markers).toHaveLength(1);
    // The newer position wins; the stale frame is discarded.
    expect(markers[0]).toHaveAttribute('data-position', JSON.stringify([13.5, 78.1]));
  });

  it('shows a non-blocking error state on a dropped socket and keeps retrying (Req 15.6, 15.9)', () => {
    const fake = createFakeStomp();
    render(
      <LiveMap
        trackingOptions={{ clientFactory: fake.factory, apiBaseUrl: 'http://localhost:8080', getToken: () => 'jwt' }}
      />,
    );

    fake.connect();
    fake.frame(rider({ riderId: 'r1', timestamp: 1000 }));
    expect(screen.getAllByTestId('rider-marker')).toHaveLength(1);

    // Socket drops -> error alert appears, but the map (and last markers) stay
    // mounted (non-blocking, Req 15.9) and the client is NOT torn down (retries).
    fake.dropSocket();
    expect(screen.getByRole('alert')).toHaveTextContent(/reconnect|disconnect|lost/i);
    expect(screen.getByTestId('connection-status')).toHaveTextContent('Disconnected');
    expect(screen.getByTestId('map')).toBeInTheDocument();
    expect(fake.deactivated).toBe(false);

    // Reconnect recovers: the error banner clears and status returns to Live.
    fake.connect();
    expect(screen.queryByRole('alert')).not.toBeInTheDocument();
    expect(screen.getByTestId('connection-status')).toHaveTextContent('Live');
  });

  it('surfaces an error when the handshake is never authorized (Req 15.9)', () => {
    const fake = createFakeStomp();
    render(
      <LiveMap
        trackingOptions={{ clientFactory: fake.factory, apiBaseUrl: 'http://localhost:8080', getToken: () => 'bad' }}
      />,
    );

    // No onConnect (gateway rejects the ?token=) -> socket errors/closes.
    fake.errorSocket();
    expect(screen.getByRole('alert')).toHaveTextContent(/error|connection/i);
    // The map remains available and the client keeps retrying.
    expect(screen.getByTestId('map')).toBeInTheDocument();
    expect(fake.deactivated).toBe(false);
  });
});
