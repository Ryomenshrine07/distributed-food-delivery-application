import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import { upsertRiders, type RiderLocationUpdate } from '@/lib/tracking-url';

/**
 * Feature: ui-modernization, Property 8: Live-map marker upsert keyed by riderId (latest wins)
 * Validates: Requirements 15.4
 *
 * Folding any sequence of updates through `upsertRiders` yields a map that:
 *   - has exactly one entry per DISTINCT riderId,
 *   - whose value is the greatest-timestamp update for that rider
 *     (ties broken by the last such update in sequence order, matching `>=`),
 *   - never mutates its inputs, and
 *   - is deterministic (equal input sequence -> equal map).
 */

// Small rider-id and timestamp pools force frequent collisions and ties so
// both the "newer wins" and the ">= tie-break" branches are exercised.
const riderIdArb = fc.constantFrom('r1', 'r2', 'r3');
const orderIdArb = fc.option(fc.constantFrom('o1', 'o2'), { nil: null });
const tsArb = fc.integer({ min: 0, max: 5 });

const updateArb: fc.Arbitrary<RiderLocationUpdate> = fc.record({
  riderId: riderIdArb,
  orderId: orderIdArb,
  latitude: fc.double({ min: -90, max: 90, noNaN: true, noDefaultInfinity: true }),
  longitude: fc.double({ min: -180, max: 180, noNaN: true, noDefaultInfinity: true }),
  timestamp: tsArb,
});

const updatesArb = fc.array(updateArb, { maxLength: 30 });

function fold(updates: RiderLocationUpdate[]): Map<string, RiderLocationUpdate> {
  return updates.reduce(
    (acc, u) => upsertRiders(acc, u),
    new Map<string, RiderLocationUpdate>(),
  );
}

// Independent reference: the last update (in sequence order) achieving the
// maximum timestamp for a given rider.
function referenceWinner(
  updates: RiderLocationUpdate[],
  riderId: string,
): RiderLocationUpdate {
  const forRider = updates.filter((u) => u.riderId === riderId);
  const maxTs = Math.max(...forRider.map((u) => u.timestamp));
  const winners = forRider.filter((u) => u.timestamp === maxTs);
  return winners[winners.length - 1];
}

describe('Feature: ui-modernization, Property 8: Live-map marker upsert keyed by riderId (latest wins)', () => {
  it('keeps exactly one entry per distinct rider (Validates 15.4)', () => {
    fc.assert(
      fc.property(updatesArb, (updates) => {
        const result = fold(updates);
        const distinctIds = new Set(updates.map((u) => u.riderId));
        expect(result.size).toBe(distinctIds.size);
        expect(new Set(result.keys())).toEqual(distinctIds);
      }),
      { numRuns: 200 },
    );
  });

  it('each entry is the greatest-timestamp update for that rider (Validates 15.4)', () => {
    fc.assert(
      fc.property(updatesArb, (updates) => {
        const result = fold(updates);
        for (const [riderId, value] of result) {
          const expected = referenceWinner(updates, riderId);
          expect(value).toBe(expected);
          expect(value.timestamp).toBe(expected.timestamp);
        }
      }),
      { numRuns: 200 },
    );
  });

  it('does not mutate the input map (Validates 15.4)', () => {
    fc.assert(
      fc.property(updatesArb, updateArb, (seed, update) => {
        const current = fold(seed);
        const before = new Map(current);
        upsertRiders(current, update);
        expect(current).toEqual(before);
      }),
      { numRuns: 200 },
    );
  });

  it('is deterministic: equal sequences produce equal maps (Validates 15.4)', () => {
    fc.assert(
      fc.property(updatesArb, (updates) => {
        expect(fold(updates)).toEqual(fold(updates));
      }),
      { numRuns: 200 },
    );
  });

  it('a later update with an equal timestamp replaces the earlier one (Validates 15.4)', () => {
    fc.assert(
      fc.property(
        riderIdArb,
        tsArb,
        fc.double({ min: -90, max: 90, noNaN: true, noDefaultInfinity: true }),
        fc.double({ min: -90, max: 90, noNaN: true, noDefaultInfinity: true }),
        (riderId, ts, latA, latB) => {
          const a: RiderLocationUpdate = { riderId, orderId: null, latitude: latA, longitude: 0, timestamp: ts };
          const b: RiderLocationUpdate = { riderId, orderId: null, latitude: latB, longitude: 0, timestamp: ts };
          const result = fold([a, b]);
          expect(result.get(riderId)).toBe(b);
        },
      ),
      { numRuns: 200 },
    );
  });
});
