import { render, screen, waitFor, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { http, HttpResponse } from 'msw';
import { describe, it, expect, vi } from 'vitest';
import { server } from '../mocks/server';
import { Orders, ORDERS_REFETCH_INTERVAL_MS } from '@/pages/Orders';

const API = 'http://localhost:8080';

const order = (over: Partial<Record<string, unknown>> = {}) => ({
  id: 'ord-001',
  customerId: 'c1',
  customerName: 'Alice',
  customerPhone: '111',
  restaurantId: 'rest-aaa',
  totalAmount: 20,
  status: 'PENDING_PAYMENT',
  createdAt: '2024-01-01T10:00:00.000Z',
  ...over,
});

const batch1 = [
  order(),
  order({ id: 'ord-002', customerName: 'Bob', restaurantId: 'rest-bbb', status: 'PREPARING' }),
  order({ id: 'ord-003', customerName: 'Carol', restaurantId: 'rest-ccc', status: 'DELIVERED' }),
];

function renderOrders() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>
        <Orders />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe('Orders page (Req 16.1, 16.2, 16.5, 16.6, 16.7)', () => {
  it('auto-refreshes the order list on the interval (Req 16.2)', async () => {
    let call = 0;
    server.use(
      http.get(`${API}/orders/admin`, () => {
        call += 1;
        return HttpResponse.json(
          call === 1 ? batch1 : [order({ id: 'ord-009', customerName: 'Dave' })],
        );
      }),
    );

    vi.useFakeTimers();
    try {
      renderOrders();
      // Resolve the initial mount fetch.
      await act(async () => {
        await vi.advanceTimersByTimeAsync(0);
      });
      expect(screen.getByText('Alice')).toBeInTheDocument();
      expect(call).toBe(1);

      // Advance one poll interval -> react-query refetches (Req 16.2), then let
      // the refetch's async chain + re-render settle.
      await act(async () => {
        await vi.advanceTimersByTimeAsync(ORDERS_REFETCH_INTERVAL_MS + 1);
      });
      await act(async () => {
        await vi.advanceTimersByTimeAsync(0);
      });

      expect(call).toBeGreaterThanOrEqual(2);
      expect(screen.getByText('Dave')).toBeInTheDocument();
      expect(screen.queryByText('Alice')).not.toBeInTheDocument();
    } finally {
      vi.useRealTimers();
    }
  });

  it('filters the list by a selected status chip (Req 16.3)', async () => {
    server.use(http.get(`${API}/orders/admin`, () => HttpResponse.json(batch1)));
    const user = userEvent.setup();
    renderOrders();

    expect(await screen.findByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('Bob')).toBeInTheDocument();
    expect(screen.getByText('Carol')).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'PREPARING' }));

    // Only the PREPARING order (Bob) remains.
    expect(screen.getByText('Bob')).toBeInTheDocument();
    expect(screen.queryByText('Alice')).not.toBeInTheDocument();
    expect(screen.queryByText('Carol')).not.toBeInTheDocument();
  });

  it('filters the list by the search box, case-insensitively (Req 16.4)', async () => {
    server.use(http.get(`${API}/orders/admin`, () => HttpResponse.json(batch1)));
    const user = userEvent.setup();
    renderOrders();

    const searchBox = await screen.findByLabelText('Search orders');

    await user.type(searchBox, 'ALICE');
    expect(screen.getByText('Alice')).toBeInTheDocument();
    expect(screen.queryByText('Bob')).not.toBeInTheDocument();
    expect(screen.queryByText('Carol')).not.toBeInTheDocument();

    // Searching by restaurant id narrows to a different order.
    await user.clear(searchBox);
    await user.type(searchBox, 'rest-bbb');
    expect(screen.getByText('Bob')).toBeInTheDocument();
    expect(screen.queryByText('Alice')).not.toBeInTheDocument();
  });

  it('accepts a PENDING_PAYMENT/CONFIRMED order and refreshes (Req 16.5, 16.7)', async () => {
    let getCount = 0;
    const acceptCalls: string[] = [];
    server.use(
      http.get(`${API}/orders/admin`, () => {
        getCount += 1;
        return HttpResponse.json(batch1);
      }),
      http.post(`${API}/orders/:id/accept`, ({ params }) => {
        acceptCalls.push(params.id as string);
        return HttpResponse.json({});
      }),
    );
    const user = userEvent.setup();
    renderOrders();

    await screen.findByText('Alice');
    await user.click(screen.getByRole('button', { name: 'Accept' }));

    await waitFor(() => expect(acceptCalls).toEqual(['ord-001']));
    // Success invalidates the query -> at least one extra GET (Req 16.7).
    await waitFor(() => expect(getCount).toBeGreaterThanOrEqual(2));
  });

  it('marks a PREPARING order ready and refreshes (Req 16.6, 16.7)', async () => {
    let getCount = 0;
    const readyCalls: string[] = [];
    server.use(
      http.get(`${API}/orders/admin`, () => {
        getCount += 1;
        return HttpResponse.json(batch1);
      }),
      http.post(`${API}/orders/:id/ready`, ({ params }) => {
        readyCalls.push(params.id as string);
        return HttpResponse.json({});
      }),
    );
    const user = userEvent.setup();
    renderOrders();

    await screen.findByText('Bob');
    await user.click(screen.getByRole('button', { name: 'Mark Ready' }));

    await waitFor(() => expect(readyCalls).toEqual(['ord-002']));
    await waitFor(() => expect(getCount).toBeGreaterThanOrEqual(2));
  });
});
