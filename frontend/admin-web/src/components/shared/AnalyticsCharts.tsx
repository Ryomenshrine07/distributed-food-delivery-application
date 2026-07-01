import { useMemo } from 'react';
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Legend,
  Line,
  LineChart,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import type { Order } from '@/services/orders';
import { aggregateOrders } from '@/lib/analytics-aggregation';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { EmptyState } from '@/components/shared/EmptyState';

// Brand-anchored categorical palette (mapped from the recolored --chart-* tokens).
const CHART_COLORS = [
  'var(--chart-1)',
  'var(--chart-2)',
  'var(--chart-3)',
  'var(--chart-4)',
  'var(--chart-5)',
];

const currency = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

/**
 * Analytics charts (Req 17.3): order-status distribution, orders-per-day, and
 * revenue-per-day, computed by pure client-side aggregation of `GET /orders/admin`.
 * Shared by the Dashboard and Analytics pages.
 */
export const AnalyticsCharts = ({ orders }: { orders: Order[] }) => {
  const { statusCounts, ordersPerDay, revenuePerDay } = useMemo(
    () => aggregateOrders(orders),
    [orders],
  );

  const statusData = useMemo(
    () =>
      Object.entries(statusCounts)
        .map(([status, count]) => ({ status: status.replace(/_/g, ' '), count }))
        .sort((a, b) => a.status.localeCompare(b.status)),
    [statusCounts],
  );

  if (orders.length === 0) {
    return (
      <EmptyState
        title="No order data yet"
        description="Charts will appear here once orders start coming in."
      />
    );
  }

  return (
    <div className="grid gap-4 lg:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>Order Status Distribution</CardTitle>
        </CardHeader>
        <CardContent>
          <div role="img" aria-label="Order status distribution" className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={statusData}
                  dataKey="count"
                  nameKey="status"
                  cx="50%"
                  cy="50%"
                  outerRadius={90}
                  label
                >
                  {statusData.map((entry, index) => (
                    <Cell key={entry.status} fill={CHART_COLORS[index % CHART_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Orders per Day</CardTitle>
        </CardHeader>
        <CardContent>
          <div role="img" aria-label="Orders per day" className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={ordersPerDay}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                <XAxis dataKey="day" fontSize={12} />
                <YAxis allowDecimals={false} fontSize={12} />
                <Tooltip />
                <Line
                  type="monotone"
                  dataKey="count"
                  name="Orders"
                  stroke="var(--chart-1)"
                  strokeWidth={2}
                  dot={false}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>

      <Card className="lg:col-span-2">
        <CardHeader>
          <CardTitle>Revenue per Day</CardTitle>
        </CardHeader>
        <CardContent>
          <div role="img" aria-label="Revenue per day" className="h-72 w-full">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={revenuePerDay}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" />
                <XAxis dataKey="day" fontSize={12} />
                <YAxis fontSize={12} />
                <Tooltip formatter={(value) => currency.format(Number(value))} />
                <Bar dataKey="revenue" name="Revenue" fill="var(--chart-1)" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};
