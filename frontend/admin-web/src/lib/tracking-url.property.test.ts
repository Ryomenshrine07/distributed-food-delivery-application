import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import { deriveTrackingWsUrl } from '@/lib/tracking-url';

/**
 * Feature: ui-modernization, Property 10: Tracking WebSocket URL derivation
 * Validates: Requirements 15.2
 *
 * For any valid `VITE_API_URL`, `deriveTrackingWsUrl`:
 *   - uses `wss:` iff the base scheme is `https:` (otherwise `ws:`),
 *   - preserves host and port exactly,
 *   - sets the path to `/ws/tracking`,
 *   - emits no query string (and no hash).
 */

// A base URL is assembled from constrained parts so every generated input is a
// valid URL that still exercises the scheme / port / query / hash branches.
const schemeArb = fc.constantFrom('http', 'https');
const hostArb = fc.constantFrom(
  'localhost',
  'example.com',
  'api.example.org',
  '127.0.0.1',
  'gateway.internal',
  'sub.domain.co',
);
const portArb = fc.option(fc.integer({ min: 1, max: 65535 }), { nil: undefined });
const pathArb = fc.constantFrom('', '/', '/api', '/gateway/v1', '/a/b/c');
const queryArb = fc.constantFrom('', '?token=abc', '?a=1&b=2', '?x=y%20z');
const hashArb = fc.constantFrom('', '#frag', '#section-2');

const baseUrlArb = fc
  .record({
    scheme: schemeArb,
    host: hostArb,
    port: portArb,
    path: pathArb,
    query: queryArb,
    hash: hashArb,
  })
  .map(({ scheme, host, port, path, query, hash }) => {
    const authority = port === undefined ? host : `${host}:${port}`;
    return { input: `${scheme}://${authority}${path}${query}${hash}`, scheme };
  });

describe('Feature: ui-modernization, Property 10: Tracking WebSocket URL derivation', () => {
  it('uses wss iff https, preserves host+port, path /ws/tracking, no query (Validates 15.2)', () => {
    fc.assert(
      fc.property(baseUrlArb, ({ input, scheme }) => {
        const inUrl = new URL(input);
        const out = deriveTrackingWsUrl(input);
        const outUrl = new URL(out);

        // Scheme: wss iff the base is https.
        expect(outUrl.protocol).toBe(scheme === 'https' ? 'wss:' : 'ws:');
        // Host+port preserved (URL#host includes the port when present).
        expect(outUrl.host).toBe(inUrl.host);
        // Path is always /ws/tracking.
        expect(outUrl.pathname).toBe('/ws/tracking');
        // No query string or hash survives.
        expect(outUrl.search).toBe('');
        expect(outUrl.hash).toBe('');
        expect(out.includes('?')).toBe(false);
        expect(out.includes('#')).toBe(false);
      }),
      { numRuns: 200 },
    );
  });

  it('emits a wss URL exactly for https bases (Validates 15.2)', () => {
    fc.assert(
      fc.property(baseUrlArb, ({ input, scheme }) => {
        const out = deriveTrackingWsUrl(input);
        expect(out.startsWith('wss://')).toBe(scheme === 'https');
        expect(out.startsWith('ws://')).toBe(scheme === 'http');
        expect(out.endsWith('/ws/tracking')).toBe(true);
      }),
      { numRuns: 200 },
    );
  });
});
