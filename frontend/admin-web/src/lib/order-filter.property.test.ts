import { describe, it, expect } from 'vitest';
import fc from 'fast-check';
import { filterOrders } from '@/lib/order-filter';
import type { Order } from '@/services/orders';

/**
 * Feature: ui-modernization, Property 9: Order filter and search predicate
 * Validates: Requirements 16.3, 16.4
 *
 * For any list of admin orders, a selected-status set, and a search term,
 * `filterOrders`:
 *   - STATUS GATE (16.3): keeps an order iff the set is empty OR contains its status,
 *   - SEARCH GATE (16.4): keeps an order iff its id / customerName / restaurantId
 *     contains the term case-insensitively (empty term matches all),
 *   - keeps ONLY orders passing both gates (soundness) and ALL such orders
 *     (completeness), preserving input order,
 *   - is case-insensitive in the search term.
 */

const STATUSES = [
  'PENDING_PAYMENT',
  'CONFIRMED',
  'PREPARING',
  'READY_FOR_PICKUP',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
  'CANCELLED',
] as const;

const statusArb = fc.constantFrom(...STATUSES);

// Small mixed-case alphabet so generated search terms frequently hit (and miss)
// the generated field values, exercising both branches of the search gate.
const charArb = fc.constantFrom('a', 'A', 'b', 'B', 'c', '1', '2', '-', ' ');
const smallStr = fc.array(charArb, { maxLength: 6 }).map((cs) => cs.join(''));

const orderArb: fc.Arbitrary<Order> = fc.record({
  id: smallStr,
  customerId: fc.constant('cust'),
  customerName: smallStr,
  customerPhone: fc.constant('000'),
  restaurantId: smallStr,
  totalAmount: fc.double({ min: 0, max: 1000, noNaN: true, noDefaultInfinity: true }),
  status: statusArb,
  createdAt: fc.constant('2024-01-01T00:00:00.000Z'),
});

const ordersArb = fc.array(orderArb, { maxLength: 25 });
const statusSetArb = fc.array(statusArb, { maxLength: 4 }).map((a) => new Set<string>(a));

// Independent reference predicate for the two gates.
const passesStatus = (o: Order, sel: Set<string>) => sel.size === 0 || sel.has(o.status);
const passesSearch = (o: Order, term: string) => {
  const t = term.toLowerCase();
  return (
    o.id.toLowerCase().includes(t) ||
    o.customerName.toLowerCase().includes(t) ||
    o.restaurantId.toLowerCase().includes(t)
  );
};

describe('Feature: ui-modernization, Property 9: Order filter and search predicate', () => {
  it('keeps exactly the orders passing both gates, in input order (Validates 16.3, 16.4)', () => {
    fc.assert(
      fc.property(ordersArb, statusSetArb, smallStr, (orders, sel, term) => {
        const result = filterOrders(orders, sel, term);
        const expected = orders.filter((o) => passesStatus(o, sel) && passesSearch(o, term));
        expect(result).toEqual(expected);
      }),
      { numRuns: 150 },
    );
  });

  it('every returned order satisfies the status gate (Validates 16.3)', () => {
    fc.assert(
      fc.property(ordersArb, statusSetArb, smallStr, (orders, sel, term) => {
        for (const o of filterOrders(orders, sel, term)) {
          expect(sel.size === 0 || sel.has(o.status)).toBe(true);
        }
      }),
      { numRuns: 150 },
    );
  });

  it('every returned order satisfies the case-insensitive search gate (Validates 16.4)', () => {
    fc.assert(
      fc.property(ordersArb, statusSetArb, smallStr, (orders, sel, term) => {
        for (const o of filterOrders(orders, sel, term)) {
          expect(passesSearch(o, term)).toBe(true);
        }
      }),
      { numRuns: 150 },
    );
  });

  it('an empty status set applies no status restriction (Validates 16.3)', () => {
    fc.assert(
      fc.property(ordersArb, smallStr, (orders, term) => {
        const result = filterOrders(orders, new Set(), term);
        const expected = orders.filter((o) => passesSearch(o, term));
        expect(result).toEqual(expected);
      }),
      { numRuns: 150 },
    );
  });

  it('an empty search term matches all orders (Validates 16.4)', () => {
    fc.assert(
      fc.property(ordersArb, statusSetArb, (orders, sel) => {
        const result = filterOrders(orders, sel, '');
        const expected = orders.filter((o) => passesStatus(o, sel));
        expect(result).toEqual(expected);
      }),
      { numRuns: 150 },
    );
  });

  it('search is case-insensitive: upper/lower/original agree (Validates 16.4)', () => {
    fc.assert(
      fc.property(ordersArb, statusSetArb, smallStr, (orders, sel, term) => {
        const base = filterOrders(orders, sel, term);
        expect(filterOrders(orders, sel, term.toUpperCase())).toEqual(base);
        expect(filterOrders(orders, sel, term.toLowerCase())).toEqual(base);
      }),
      { numRuns: 150 },
    );
  });
});
