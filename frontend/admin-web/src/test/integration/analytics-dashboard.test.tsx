import type { ReactElement } from 'react';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { http, HttpResponse } from 'msw';
import { describe, it, expect } from 'vitest';
import { server } from '../mocks/server';
import { Dashboard } from '@/pages/Dashboard';
import { Analytics } from '@/pages/Analytics';

const API = 'http://localhost:8080';

const analyticsPayload = {
  totalOrders: 128,
  totalRevenue: 5678.9,
  pendingOrders: 7,
  deliveredOrders: 42,
};

const ordersPayload = [
  { id: 'o1', customerId: 'c1', customerName: 'Alice', customerPhone: '111', restaurantId: 'r1', totalAmount: 20, status: 'DELIVERED', createdAt: '2024-01-01T10:00:00.000Z' },
  { id: 'o2', customerId: 'c2', customerName: 'Bob', customerPhone: '222', restaurantId: 'r2', totalAmount: 35.5, status: 'PENDING_PAYMENT', createdAt: '2024-01-02T11:00:00.000Z' },
  { id: 'o3', customerId: 'c3', customerName: 'Cara', customerPhone: '333', restaurantId: 'r1', totalAmount: 12, status: 'DELIVERED', createdAt: '2024-01-02T12:00:00.000Z' },
];

function renderPage(ui: ReactElement) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>{ui}</MemoryRouter>
    </QueryClientProvider>,
  );
}

const okHandlers = () => [
  http.get(`${API}/analytics/admin`, () => HttpResponse.json(analyticsPayload)),
  http.get(`${API}/orders/admin`, () => HttpResponse.json(ordersPayload)),
];

describe('Dashboard (Req 17.1, 17.2, 17.3)', () => {
  it('renders the real analytics metrics from /analytics/admin', async () => {
    server.use(...okHandlers());
    renderPage(<Dashboard />);

    expect(await screen.findByText('$5,678.90')).toBeInTheDocument(); // totalRevenue
    expect(screen.getByText('128')).toBeInTheDocument(); // totalOrders
    expect(screen.getByText('42')).toBeInTheDocument(); // deliveredOrders
    expect(screen.getByText('Total Revenue')).toBeInTheDocument();
    expect(screen.getByText('Delivered Orders')).toBeInTheDocument();
  });

  it('no longer shows the hardcoded stub or the Phase 3 PendingFeature banner', async () => {
    server.use(...okHandlers());
    renderPage(<Dashboard />);

    await screen.findByText('$5,678.90');
    expect(screen.queryByText('$45,231.89')).not.toBeInTheDocument();
    expect(screen.queryByText(/Phase 3/i)).not.toBeInTheDocument();
    expect(screen.queryByText(/Live Order Map & Analytics Charts/i)).not.toBeInTheDocument();
  });

  it('renders the analytics charts computed from /orders/admin', async () => {
    server.use(...okHandlers());
    renderPage(<Dashboard />);

    expect(await screen.findByText('Order Status Distribution')).toBeInTheDocument();
    expect(screen.getByText('Orders per Day')).toBeInTheDocument();
    expect(screen.getByText('Revenue per Day')).toBeInTheDocument();
  });

  it('shows an error state and no fabricated numbers when analytics fails (Req 17.5)', async () => {
    server.use(
      http.get(`${API}/analytics/admin`, () => new HttpResponse(null, { status: 500 })),
      http.get(`${API}/orders/admin`, () => HttpResponse.json(ordersPayload)),
    );
    renderPage(<Dashboard />);

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    // No fabricated fallback and no (unavailable) real metric.
    expect(screen.queryByText('$45,231.89')).not.toBeInTheDocument();
    expect(screen.queryByText('$5,678.90')).not.toBeInTheDocument();
    expect(screen.queryByText('128')).not.toBeInTheDocument();
  });
});

describe('Analytics (Req 17.1, 17.3, 17.5, 17.6)', () => {
  it('renders the real metrics and charts', async () => {
    server.use(...okHandlers());
    renderPage(<Analytics />);

    expect(await screen.findByText('$5,678.90')).toBeInTheDocument();
    expect(screen.getByText('128')).toBeInTheDocument();
    expect(await screen.findByText('Order Status Distribution')).toBeInTheDocument();
    expect(screen.getByText('Revenue per Day')).toBeInTheDocument();
  });

  it('shows an error state without fabricated numbers when the fetch fails (Req 17.5)', async () => {
    server.use(
      http.get(`${API}/analytics/admin`, () => new HttpResponse(null, { status: 500 })),
      http.get(`${API}/orders/admin`, () => HttpResponse.json(ordersPayload)),
    );
    renderPage(<Analytics />);

    expect(await screen.findByRole('alert')).toBeInTheDocument();
    expect(screen.queryByText('$5,678.90')).not.toBeInTheDocument();
    expect(screen.queryByText('$45,231.89')).not.toBeInTheDocument();
  });
});
