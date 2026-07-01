import { render, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { http, HttpResponse } from 'msw';
import { describe, it, expect } from 'vitest';
import { server } from '../mocks/server';
import { DeliveryPartners } from '@/pages/DeliveryPartners';

const API = 'http://localhost:8080';

const partners = [
  { id: 'p1', name: 'Ann', phone: '111', online: true, available: true, currentAssignmentId: null, lastSeen: '2024-01-01T00:00:00.000Z' },
  { id: 'p2', name: 'Ben', phone: '222', online: false, available: false, currentAssignmentId: null, lastSeen: '2024-01-01T00:00:00.000Z' },
  { id: 'p3', name: 'Cid', phone: '333', online: true, available: false, currentAssignmentId: 'asg-1', lastSeen: '2024-01-01T00:00:00.000Z' },
];

function renderPartners() {
  return render(
    <MemoryRouter>
      <DeliveryPartners />
    </MemoryRouter>,
  );
}

describe('DeliveryPartners page (Req 14.3, 14.5)', () => {
  it('shows only online partners when the Online filter is selected (Req 14.3)', async () => {
    server.use(http.get(`${API}/api/delivery/partners/admin`, () => HttpResponse.json(partners)));
    const user = userEvent.setup();
    renderPartners();

    await screen.findByText('Ann');
    await user.click(screen.getByRole('button', { name: 'Online' }));

    expect(screen.getByText('Ann')).toBeInTheDocument();
    expect(screen.getByText('Cid')).toBeInTheDocument();
    expect(screen.queryByText('Ben')).not.toBeInTheDocument();
  });

  it('shows only assigned partners when the Assigned filter is selected (Req 14.3)', async () => {
    server.use(http.get(`${API}/api/delivery/partners/admin`, () => HttpResponse.json(partners)));
    const user = userEvent.setup();
    renderPartners();

    await screen.findByText('Cid');
    await user.click(screen.getByRole('button', { name: 'Assigned' }));

    expect(screen.getByText('Cid')).toBeInTheDocument();
    expect(screen.queryByText('Ann')).not.toBeInTheDocument();
    expect(screen.queryByText('Ben')).not.toBeInTheDocument();
  });

  it('preserves the online/offline toggle and refresh behavior (Req 14.5)', async () => {
    let getCount = 0;
    const offlineCalls: string[] = [];
    server.use(
      http.get(`${API}/api/delivery/partners/admin`, () => {
        getCount += 1;
        return HttpResponse.json(partners);
      }),
      http.post(`${API}/api/delivery/partners/:id/offline`, ({ params }) => {
        offlineCalls.push(params.id as string);
        return HttpResponse.json({});
      }),
    );
    const user = userEvent.setup();
    renderPartners();

    await screen.findByText('Ann');
    await waitFor(() => expect(getCount).toBe(1));

    // Toggle Ann (online) offline -> POST .../p1/offline, then a refetch.
    const annRow = screen.getByText('Ann').closest('tr') as HTMLElement;
    await user.click(within(annRow).getByRole('button', { name: 'Force Offline' }));

    await waitFor(() => expect(offlineCalls).toEqual(['p1']));
    await waitFor(() => expect(getCount).toBeGreaterThanOrEqual(2));

    // Manual refresh reloads the list again.
    const countBeforeRefresh = getCount;
    await user.click(screen.getByRole('button', { name: 'Refresh List' }));
    await waitFor(() => expect(getCount).toBeGreaterThan(countBeforeRefresh));
  });
});
