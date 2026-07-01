import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { http, HttpResponse } from 'msw';
import { describe, it, expect } from 'vitest';
import { server } from '../mocks/server';
import { Restaurants } from '@/pages/Restaurants';

const API = 'http://localhost:8080';

const restaurant = (isActive: boolean) => ({
  id: '1',
  name: 'Test Restaurant',
  description: 'A great place',
  address: { street: '123 Test St', city: 'New York', state: 'NY', zipCode: '10001', country: 'USA' },
  isActive,
  ownerId: 'owner1',
});

const page = (isActive: boolean) => ({
  data: { content: [restaurant(isActive)], totalElements: 1, totalPages: 1, number: 0, size: 20 },
});

function renderRestaurants() {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>
        <Restaurants />
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

describe('Restaurants status toggle (Req 13.3, 13.4, 13.5)', () => {
  it('sends PATCH {active} and refreshes the list on success (Req 13.3, 13.4)', async () => {
    let getCount = 0;
    let current = true;
    let patchBody: { active?: boolean } | null = null;
    const patchedIds: string[] = [];

    server.use(
      http.get(`${API}/restaurants`, () => {
        getCount += 1;
        return HttpResponse.json(page(current));
      }),
      http.patch(`${API}/restaurants/:id/status`, async ({ request, params }) => {
        patchBody = (await request.json()) as { active?: boolean };
        patchedIds.push(params.id as string);
        current = patchBody.active ?? current;
        return HttpResponse.json({ data: restaurant(current) });
      }),
    );

    const user = userEvent.setup();
    renderRestaurants();

    await screen.findByText('Test Restaurant');
    expect(screen.getByText('Active')).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'Deactivate' }));

    // PATCH carries the new active value for the correct restaurant (Req 13.3).
    await waitFor(() => expect(patchedIds).toEqual(['1']));
    expect(patchBody).toEqual({ active: false });

    // Success refreshes the list so the displayed status flips (Req 13.4).
    await waitFor(() => expect(getCount).toBeGreaterThanOrEqual(2));
    await waitFor(() => expect(screen.getByText('Inactive')).toBeInTheDocument());
  });

  it('keeps the prior status and surfaces an error when the update fails 4xx (Req 13.5)', async () => {
    server.use(
      http.get(`${API}/restaurants`, () => HttpResponse.json(page(true))),
      http.patch(`${API}/restaurants/:id/status`, () => new HttpResponse(null, { status: 400 })),
    );

    const user = userEvent.setup();
    renderRestaurants();

    await screen.findByText('Test Restaurant');
    expect(screen.getByText('Active')).toBeInTheDocument();

    await user.click(screen.getByRole('button', { name: 'Deactivate' }));

    // Error surfaced (Req 13.5)...
    expect(await screen.findByRole('alert')).toBeInTheDocument();
    // ...and the previously displayed status is retained (no optimistic desync).
    expect(screen.getByText('Active')).toBeInTheDocument();
    expect(screen.queryByText('Inactive')).not.toBeInTheDocument();
  });
});
