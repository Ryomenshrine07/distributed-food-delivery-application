import { http, HttpResponse } from 'msw';
import { describe, it, expect, afterEach } from 'vitest';
import { server } from '../mocks/server';
import { api } from '@/lib/api';
import { useSessionStore } from '@/store/session';
import type { AuthSession } from '@/types/auth';

const API = 'http://localhost:8080';

const session: AuthSession = {
  token: 'jwt-token-123',
  user: { id: 'u1', name: 'Admin', email: 'admin@example.com', role: 'ADMIN' },
};

afterEach(() => {
  useSessionStore.getState().logout();
});

/**
 * Preserved auth/session behavior (Req 18.6) — this MUST be unchanged by the
 * modernization. The axios client attaches the Bearer token, and a 401 logs the
 * operator out and redirects to /login.
 */
describe('axios auth behavior (Req 18.6)', () => {
  it('attaches the Authorization: Bearer token to requests', async () => {
    useSessionStore.getState().setSession(session);

    let seenAuth: string | null = null;
    server.use(
      http.get(`${API}/orders/admin`, ({ request }) => {
        seenAuth = request.headers.get('authorization');
        return HttpResponse.json([]);
      }),
    );

    await api.get('/orders/admin');
    expect(seenAuth).toBe('Bearer jwt-token-123');
  });

  it('does not attach an Authorization header when there is no session', async () => {
    let seenAuth: string | null = 'unset';
    server.use(
      http.get(`${API}/orders/admin`, ({ request }) => {
        seenAuth = request.headers.get('authorization');
        return HttpResponse.json([]);
      }),
    );

    await api.get('/orders/admin');
    expect(seenAuth).toBeNull();
  });

  it('on a 401 it logs out and redirects to /login', async () => {
    useSessionStore.getState().setSession(session);
    expect(useSessionStore.getState().session).not.toBeNull();

    // Replace window.location with a complete mock whose `href` setter is
    // observable. It keeps a valid href getter so axios's same-origin logic
    // still works and the 401 response reaches the interceptor.
    const originalDescriptor = Object.getOwnPropertyDescriptor(window, 'location');
    let capturedHref = '';
    const locationMock = {
      origin: 'http://localhost',
      protocol: 'http:',
      host: 'localhost',
      hostname: 'localhost',
      port: '',
      pathname: '/',
      search: '',
      hash: '',
      assign: () => {},
      replace: () => {},
      reload: () => {},
      get href() {
        return capturedHref || 'http://localhost/';
      },
      set href(value: string) {
        capturedHref = value;
      },
    } as unknown as Location;
    Object.defineProperty(window, 'location', { configurable: true, value: locationMock });

    server.use(
      http.get(`${API}/orders/admin`, () => new HttpResponse(null, { status: 401 })),
    );

    try {
      await expect(api.get('/orders/admin')).rejects.toBeDefined();

      expect(useSessionStore.getState().session).toBeNull();
      expect(capturedHref).toBe('/login');
    } finally {
      if (originalDescriptor) {
        Object.defineProperty(window, 'location', originalDescriptor);
      }
    }
  });
});
