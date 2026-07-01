import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import { aggregateOrders } from '@/lib/analytics-aggregation';
import type { Order } from '@/services/orders';

/**
 * Feature: ui-modernization, Property 7: Analytics aggregation determinism and totals
 * Validates: Requirements 17.3, 17.4
 *
 * For any list of admin orders, `aggregateOrders`:
 *   - is deterministic (equal input -> equal output),
 *   - status counts sum to the number of orders,
 *   - every order is counted in exactly one ordersPerDay day-bucket,
 *   - each day's revenuePerDay equals the sum of totalAmount for that day's orders.
 */

const statusArb = fc.constantFrom(
  'PENDING_PAYMENT',
  'CONFIRMED',
  'PREPARING',
  'READY_FOR_PICKUP',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
  'CANCELLED',
);

const orderArb: fc.Arbitrary<Order> = fc.record({
  id: fc.string(),
  customerId: fc.string(),
  customerName: fc.string(),
  customerPhone: fc.string(),
  restaurantId: fc.string(),
  totalAmount: fc.double({ min: 0, max: 10000, noNaN: true, noDefaultInfinity: true }),
  status: statusArb,
  createdAt: fc
    .date({
      min: new Date('2020-01-01T00:00:00.000Z'),
      max: new Date('2025-12-31T23:59:59.999Z'),
    })
    .map((d) => d.toISOString()),
});

const ordersArb = fc.array(orderArb, { maxLength: 40 });

// Mirror of the module's (private) day-bucketing, for independent verification.
const dayKey = (createdAt: string) => new Date(Date.parse(createdAt)).toISOString().slice(0, 10);

describe('Feature: ui-modernization, Property 7: Analytics aggregation determinism and totals', () => {
  it('is deterministic: equal input produces equal output (Validates 17.3)', () => {
    fc.assert(
      fc.property(ordersArb, (orders) => {
        const a = aggregateOrders(orders);
        // A structurally-equal but distinct array (new objects) must yield equal output,
        // proving the result depends only on input values, not identity or wall-clock.
        const b = aggregateOrders(orders.map((o) => ({ ...o })));
        expect(a).toEqual(b);
      }),
      { numRuns: 100 },
    );
  });

  it('statusCounts sum to orders.length (Validates 17.4)', () => {
    fc.assert(
      fc.property(ordersArb, (orders) => {
        const { statusCounts } = aggregateOrders(orders);
        const total = Object.values(statusCounts).reduce((sum, n) => sum + n, 0);
        expect(total).toBe(orders.length);
      }),
      { numRuns: 100 },
    );
  });

  it('every order falls in exactly one ordersPerDay bucket (Validates 17.4)', () => {
    fc.assert(
      fc.property(ordersArb, (orders) => {
        const { ordersPerDay } = aggregateOrders(orders);
        // Buckets partition the orders: counts sum to the total and day keys are unique.
        const totalCount = ordersPerDay.reduce((sum, d) => sum + d.count, 0);
        expect(totalCount).toBe(orders.length);
        const days = ordersPerDay.map((d) => d.day);
        expect(new Set(days).size).toBe(days.length);
      }),
      { numRuns: 100 },
    );
  });

  it("each day's revenue equals the sum of totalAmount for that day (Validates 17.4)", () => {
    fc.assert(
      fc.property(ordersArb, (orders) => {
        const { revenuePerDay } = aggregateOrders(orders);
        for (const { day, revenue } of revenuePerDay) {
          const expected = orders
            .filter((o) => dayKey(o.createdAt) === day)
            .reduce((sum, o) => sum + o.totalAmount, 0);
          expect(revenue).toBeCloseTo(expected, 6);
        }
      }),
      { numRuns: 100 },
    );
  });
});
