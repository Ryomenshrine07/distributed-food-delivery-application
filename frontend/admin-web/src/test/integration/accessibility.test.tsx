import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { http, HttpResponse } from 'msw';
import { describe, it, expect, beforeAll } from 'vitest';
import type { ReactNode } from 'react';
import axe from 'axe-core';
import { server } from '../mocks/server';
import { DeliveryPartners } from '@/pages/DeliveryPartners';
import { Restaurants } from '@/pages/Restaurants';

const API = 'http://localhost:8080';

const partners = [
  { id: 'p1', name: 'Ann', phone: '111', online: true, available: true, currentAssignmentId: null, lastSeen: '2024-01-01T00:00:00.000Z' },
  { id: 'p2', name: 'Ben', phone: '222', online: false, available: false, currentAssignmentId: null, lastSeen: '2024-01-01T00:00:00.000Z' },
];

// The real app renders pages inside AppShell's <main> landmark, with lang/title
// set by index.html. Reproduce that framing so document-level a11y rules
// (html-has-lang, document-title, region) reflect production, not the fragment.
beforeAll(() => {
  document.documentElement.lang = 'en';
  document.title = 'Admin Portal';
});

function renderPage(ui: ReactNode) {
  const queryClient = new QueryClient({ defaultOptions: { queries: { retry: false } } });
  return render(
    <QueryClientProvider client={queryClient}>
      <MemoryRouter>
        <main>{ui}</main>
      </MemoryRouter>
    </QueryClientProvider>,
  );
}

/** Serious/critical axe violations only (Req 18.4); jsdom can't compute color. */
async function seriousViolations(container: HTMLElement): Promise<string[]> {
  const results = await axe.run(container, {
    rules: { 'color-contrast': { enabled: false } },
  });
  return results.violations
    .filter((v) => v.impact === 'serious' || v.impact === 'critical')
    .map((v) => `${v.id}: ${v.help}`);
}

describe('Admin accessibility (Req 18.1-18.4)', () => {
  it('DeliveryPartners has no serious axe violations (Req 18.4)', async () => {
    server.use(http.get(`${API}/api/delivery/partners/admin`, () => HttpResponse.json(partners)));
    const { container } = renderPage(<DeliveryPartners />);
    await screen.findByText('Ann');

    expect(await seriousViolations(container)).toEqual([]);
  });

  it('Restaurants has no serious axe violations (Req 18.4)', async () => {
    // Uses the default /restaurants handler from mocks/server.ts.
    const { container } = renderPage(<Restaurants />);
    await screen.findByText('Test Restaurant');

    expect(await seriousViolations(container)).toEqual([]);
  });

  it('renders a semantic table with associated column headers (Req 18.2)', async () => {
    server.use(http.get(`${API}/api/delivery/partners/admin`, () => HttpResponse.json(partners)));
    renderPage(<DeliveryPartners />);
    await screen.findByText('Ann');

    expect(screen.getByRole('table')).toBeInTheDocument();
    const headerNames = screen.getAllByRole('columnheader').map((h) => h.textContent);
    expect(headerNames).toEqual(
      expect.arrayContaining(['Name', 'Phone', 'Status', 'Availability']),
    );
  });

  it('exposes accessible names on interactive controls (Req 18.1)', async () => {
    server.use(http.get(`${API}/api/delivery/partners/admin`, () => HttpResponse.json(partners)));
    renderPage(<DeliveryPartners />);
    await screen.findByText('Ann');

    expect(screen.getByRole('button', { name: 'Refresh List' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Online' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Available' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Assigned' })).toBeInTheDocument();
  });

  it('controls are keyboard-focusable (Req 18.3)', async () => {
    server.use(http.get(`${API}/api/delivery/partners/admin`, () => HttpResponse.json(partners)));
    renderPage(<DeliveryPartners />);
    await screen.findByText('Ann');

    const refresh = screen.getByRole('button', { name: 'Refresh List' });
    expect(refresh).not.toBeDisabled();
    refresh.focus();
    expect(refresh).toHaveFocus();

    const onlineFilter = screen.getByRole('button', { name: 'Online' });
    onlineFilter.focus();
    expect(onlineFilter).toHaveFocus();
  });
});

/**
 * WCAG AA contrast for the documented brand-on-surface pairs (Req 18.5).
 *
 * jsdom cannot compute rendered contrast, so we check the documented hex values
 * directly. Brand_Green #2B9E49 meets the AA threshold for UI components and
 * large/bold text (>= 3:1); the darker #1F7A38 additionally meets AA for normal
 * body text (>= 4.5:1). Full conformance still requires manual review.
 */
describe('Brand contrast (Req 18.5)', () => {
  const srgbToLinear = (c: number) =>
    c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);

  const relativeLuminance = (hex: string) => {
    const n = parseInt(hex.replace('#', ''), 16);
    const r = srgbToLinear(((n >> 16) & 0xff) / 255);
    const g = srgbToLinear(((n >> 8) & 0xff) / 255);
    const b = srgbToLinear((n & 0xff) / 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  };

  const contrast = (a: string, b: string) => {
    const la = relativeLuminance(a);
    const lb = relativeLuminance(b);
    return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
  };

  const BRAND = '#2B9E49';
  const BRAND_DARK = '#1F7A38';
  const WHITE = '#FFFFFF';

  it('Brand_Green meets AA for UI components / large text on white (>= 3:1)', () => {
    expect(contrast(BRAND, WHITE)).toBeGreaterThanOrEqual(3);
  });

  it('white-on-Brand_Green (primary button) meets AA for UI components (>= 3:1)', () => {
    expect(contrast(WHITE, BRAND)).toBeGreaterThanOrEqual(3);
  });

  it('the darker brand shade meets AA for normal body text on white (>= 4.5:1)', () => {
    expect(contrast(BRAND_DARK, WHITE)).toBeGreaterThanOrEqual(4.5);
  });
});
