import '@testing-library/jest-dom';
import { server } from './mocks/server';
import { beforeAll, afterEach, afterAll } from 'vitest';

// This environment doesn't provide a writable `localStorage`, but zustand's
// `persist` middleware (used by the session store) calls `setItem`. Install a
// simple in-memory implementation before any store module captures the
// reference so persisted stores work in tests.
function installMemoryStorage() {
  const store = new Map<string, string>();
  const storage = {
    getItem: (key: string) => (store.has(key) ? store.get(key)! : null),
    setItem: (key: string, value: string) => {
      store.set(key, String(value));
    },
    removeItem: (key: string) => {
      store.delete(key);
    },
    clear: () => {
      store.clear();
    },
    key: (index: number) => Array.from(store.keys())[index] ?? null,
    get length() {
      return store.size;
    },
  } as Storage;

  Object.defineProperty(globalThis, 'localStorage', { configurable: true, value: storage });
  if (typeof window !== 'undefined') {
    Object.defineProperty(window, 'localStorage', { configurable: true, value: storage });
  }
}

installMemoryStorage();

// jsdom lacks ResizeObserver, which recharts' ResponsiveContainer relies on.
// A no-op mock lets chart-bearing components render in tests without throwing.
class ResizeObserverMock {
  observe() {}
  unobserve() {}
  disconnect() {}
}

if (!('ResizeObserver' in globalThis)) {
  (globalThis as unknown as { ResizeObserver: typeof ResizeObserverMock }).ResizeObserver =
    ResizeObserverMock;
}

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
