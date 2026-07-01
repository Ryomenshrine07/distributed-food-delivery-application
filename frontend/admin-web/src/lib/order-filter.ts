import type { Order } from '@/services/orders';

/**
 * Pure order filter + search predicate (Req 16.3, 16.4).
 *
 * `filterOrders` is a PURE function used by the admin Orders page to combine the
 * status-chip filter and the free-text search box:
 *
 *   - STATUS GATE (Req 16.3): an order passes when `selectedStatuses` is empty
 *     (no chip selected -> show all) OR the order's status is in the set.
 *   - SEARCH GATE (Req 16.4): an order passes when its id, customerName, or
 *     restaurantId contains `search` as a case-insensitive substring. An empty
 *     search term matches every order (JS `"...".includes("")` is always true,
 *     so the empty-term-matches-all rule needs no special-casing).
 *
 * The result is those orders passing BOTH gates, in the original input order.
 */
export function filterOrders(
  orders: Order[],
  selectedStatuses: Set<string>,
  search: string,
): Order[] {
  const term = search.toLowerCase();

  return orders.filter((order) => {
    const statusOk = selectedStatuses.size === 0 || selectedStatuses.has(order.status);
    if (!statusOk) return false;

    return (
      (order.id ?? '').toLowerCase().includes(term) ||
      (order.customerName ?? '').toLowerCase().includes(term) ||
      (order.restaurantId ?? '').toLowerCase().includes(term)
    );
  });
}
