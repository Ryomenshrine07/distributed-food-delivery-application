import type { Order } from '@/services/orders';

/**
 * Client-side analytics aggregation (Req 17.3, 17.4).
 *
 * `aggregateOrders` is a PURE, deterministic function: equal inputs always produce
 * equal outputs, with no dependence on wall-clock time, locale, or machine timezone.
 * It underpins the dashboard charts (order-status distribution, orders-per-day,
 * revenue-per-day), all derived from the existing `GET /orders/admin` endpoint —
 * no invented analytics endpoints (Req 17.6).
 */
export interface OrderAggregates {
  /** Count of orders per status. The counts sum to `orders.length`. */
  statusCounts: Record<string, number>;
  /** Order count per calendar day, sorted ascending by day. */
  ordersPerDay: { day: string; count: number }[];
  /** Summed `totalAmount` per calendar day, sorted ascending by day. */
  revenuePerDay: { day: string; revenue: number }[];
}

/**
 * Deterministic calendar-day bucket key for an order.
 *
 * Normalizes `createdAt` to a UTC `YYYY-MM-DD` string so bucketing does not depend
 * on the machine's local timezone. Unparseable timestamps fall into a stable
 * `"unknown"` bucket (keeps the "every order in exactly one bucket" invariant total).
 */
function dayKey(createdAt: string): string {
  const time = Date.parse(createdAt);
  if (Number.isNaN(time)) return 'unknown';
  return new Date(time).toISOString().slice(0, 10);
}

export function aggregateOrders(orders: Order[]): OrderAggregates {
  const statusCounts: Record<string, number> = {};
  const ordersByDay = new Map<string, number>();
  const revenueByDay = new Map<string, number>();

  for (const order of orders) {
    statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;

    const day = dayKey(order.createdAt);
    ordersByDay.set(day, (ordersByDay.get(day) ?? 0) + 1);

    const amount = Number.isFinite(order.totalAmount) ? order.totalAmount : 0;
    revenueByDay.set(day, (revenueByDay.get(day) ?? 0) + amount);
  }

  // Deterministic ordering: day keys sort lexicographically == chronologically.
  const days = [...ordersByDay.keys()].sort();
  const ordersPerDay = days.map((day) => ({ day, count: ordersByDay.get(day)! }));
  const revenuePerDay = days.map((day) => ({ day, revenue: revenueByDay.get(day)! }));

  return { statusCounts, ordersPerDay, revenuePerDay };
}
