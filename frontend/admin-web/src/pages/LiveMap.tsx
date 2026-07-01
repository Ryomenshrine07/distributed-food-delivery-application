import 'leaflet/dist/leaflet.css';
import L from 'leaflet';
import { MapContainer, Marker, Popup, TileLayer } from 'react-leaflet';
import { Loader2, MapPin, Radio, WifiOff } from 'lucide-react';
import { PageHeader } from '@/components/shared/PageHeader';
import { cn } from '@/lib/utils';
import { useRiderTracking, type TrackingClientOptions } from '@/services/tracking';

// Centered on the operating region; the map re-centers naturally as markers
// appear. OpenStreetMap tiles need no provider API key (Req 15.7).
const DEFAULT_CENTER: [number, number] = [20.5937, 78.9629];
const DEFAULT_ZOOM = 5;

// Asset-free brand-green "puck" so we never depend on Leaflet's bundled marker
// PNGs (which break without extra bundler wiring).
const riderIcon = L.divIcon({
  className: 'rider-marker',
  html:
    '<span style="display:block;width:14px;height:14px;border-radius:9999px;' +
    'background:#2B9E49;border:2px solid #ffffff;box-shadow:0 0 0 1px rgba(0,0,0,0.25)"></span>',
  iconSize: [18, 18],
  iconAnchor: [9, 9],
});

function formatLastSeen(lastEventAt: number | null): string {
  if (lastEventAt == null) return 'Waiting for updates…';
  return `Last update ${new Date(lastEventAt).toLocaleTimeString()}`;
}

export interface LiveMapProps {
  /** Test seam: inject a fake STOMP client / base URL / token. */
  trackingOptions?: TrackingClientOptions;
}

export const LiveMap = ({ trackingOptions }: LiveMapProps = {}) => {
  const { connectionState, riders, lastError, lastEventAt } =
    useRiderTracking(trackingOptions);

  const riderList = Array.from(riders.values());
  const isConnected = connectionState === 'connected';
  const isError = connectionState === 'error';

  const statusLabel = isConnected ? 'Live' : isError ? 'Disconnected' : 'Connecting';

  return (
    <div className="space-y-6">
      <PageHeader
        title="Live Rider Map"
        description="Monitor active delivery riders in real time."
      />

      <div
        className="flex flex-wrap items-center gap-4 text-sm"
        aria-label="Live tracking summary"
      >
        <span
          data-testid="rider-count"
          className="inline-flex items-center gap-2 font-medium text-foreground"
        >
          <MapPin className="h-4 w-4 text-primary" aria-hidden="true" />
          Active riders: {riderList.length}
        </span>
        <span data-testid="last-seen" className="text-muted-foreground">
          {formatLastSeen(lastEventAt)}
        </span>
        <span
          data-testid="connection-status"
          className={cn(
            'inline-flex items-center gap-2 rounded-full px-3 py-1 text-xs font-medium',
            isConnected && 'bg-success/15 text-success',
            isError && 'bg-destructive/15 text-destructive',
            !isConnected && !isError && 'bg-muted text-muted-foreground',
          )}
        >
          <Radio className="h-3.5 w-3.5" aria-hidden="true" />
          {statusLabel}
        </span>
      </div>

      {/* Non-blocking connection banner: the map stays visible underneath (Req 15.9). */}
      {!isConnected && (
        <div
          role={isError ? 'alert' : 'status'}
          className={cn(
            'flex items-center gap-3 rounded-md border px-4 py-3 text-sm',
            isError
              ? 'border-destructive/30 bg-destructive/10 text-destructive'
              : 'border-border bg-muted text-muted-foreground',
          )}
        >
          {isError ? (
            <WifiOff className="h-4 w-4 shrink-0" aria-hidden="true" />
          ) : (
            <Loader2 className="h-4 w-4 shrink-0 animate-spin" aria-hidden="true" />
          )}
          <span>
            {isError
              ? (lastError ?? 'Connection lost. Retrying…')
              : 'Connecting to live tracking…'}
          </span>
        </div>
      )}

      <div className="overflow-hidden rounded-lg border">
        <MapContainer
          center={DEFAULT_CENTER}
          zoom={DEFAULT_ZOOM}
          scrollWheelZoom
          className="h-[70vh] w-full"
          aria-label="Live rider map"
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          {riderList.map((rider) => (
            <Marker
              key={rider.riderId}
              position={[rider.latitude, rider.longitude]}
              icon={riderIcon}
            >
              <Popup>
                <span className="font-medium">Rider {rider.riderId}</span>
                {rider.orderId ? <div>Order {rider.orderId}</div> : <div>Idle</div>}
              </Popup>
            </Marker>
          ))}
        </MapContainer>
      </div>
    </div>
  );
};
