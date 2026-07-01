# Implementation Plan — Admin Web Dashboard

## Overview

This plan converts the Admin Web Dashboard design into incremental, test-driven coding tasks for the React client under `frontend/admin-web`. The build order lays the infrastructure first (scaffold → theme → types → networking → stores → routing), implements verified-endpoint features (auth → layout shell → restaurant browse), then implements all gap-backed features as real UI with `PendingFeature` placeholder overlays (dashboard → orders → delivery partners → customers → analytics → notifications), and finishes with settings, accessibility, performance, and an end-to-end integration test.

**Conventions:**
- All TypeScript; `strict: true` in `tsconfig.json`; no `any`.
- Server state via TanStack Query v5 hooks in `src/hooks/`; client state via Zustand slices in `src/stores/`.
- Backend-gap features are built with full UI but wrapped in `<PendingFeature>` — disabled controls, visible endpoint badge, gap reference in comments (`// TODO: Gap N`).
- All service modules are swappable: placeholder implementations return typed mock data; real implementations call `apiClient`. The component does not change between them.
- Sub-tasks marked `*` are test tasks. Tests use Vitest + React Testing Library + MSW.

---

## Tasks

- [ ] 1. Scaffold the project
  - Initialise a Vite + React + TypeScript project at `frontend/admin-web` using `npm create vite@latest admin-web -- --template react-ts`
  - Install dependencies: react-router-dom, @tanstack/react-query, @tanstack/react-table, @tanstack/react-virtual, zustand, axios, react-hook-form, @hookform/resolvers, zod, recharts, clsx, tailwind-merge, lucide-react, date-fns
  - Install shadcn/ui (CLI init), configure Tailwind CSS v3 with a custom design-token palette, add `dark` class strategy
  - Install dev dependencies: vitest, @vitest/ui, @testing-library/react, @testing-library/user-event, @testing-library/jest-dom, msw, @axe-core/react, jsdom
  - Configure `tsconfig.json` (`strict: true`, path aliases: `@/*` → `src/*`), `vite.config.ts` (test: jsdom, setupFiles), `tailwind.config.ts` (content paths, custom colors), `.env.example` (`VITE_API_BASE_URL`)
  - Create `src/test/setup.ts` (imports `@testing-library/jest-dom`, starts MSW server), `src/test/utils.tsx` (`renderWithProviders` wrapping QueryClientProvider + RouterProvider + Zustand reset)
  - Target: `frontend/admin-web/` (package.json, vite.config.ts, tsconfig.json, tailwind.config.ts, src/main.tsx, src/test/)
  - _Requirements: 18, 19, 20_

  - [ ] 1.1 Smoke test: app renders and TypeScript compiles clean
    - Verify `npm run build` exits 0 and `npm run test` passes with empty test suite
    - Target: CI / local verification

- [ ] 2. Implement design tokens and theming
  - Define Tailwind CSS custom colours as CSS variables (`:root` and `.dark`): primary (brand), surface, muted, destructive, success, warning, border, text-primary, text-secondary
  - Configure `tailwind.config.ts` to reference the CSS variables so all shadcn/ui components inherit the admin colour palette
  - Implement `ThemeProvider` component that reads `themeStore.theme` and applies the `dark` class to `<html>`; handle `system` mode via `window.matchMedia`
  - Add `src/app.tsx` wiring `ThemeProvider` around the `RouterProvider`
  - Target: `src/styles/tokens.css`, `tailwind.config.ts`, `src/components/theme-provider.tsx`, `src/app.tsx`
  - _Requirements: 15, 21_

  - [ ] 2.1 Unit test: ThemeProvider dark-class toggling
    - Theme `dark` adds class to `<html>`; theme `light` removes it; theme `system` follows `matchMedia` mock
    - Target: `src/components/__tests__/theme-provider.test.tsx`

- [ ] 3. Implement core types and error model
  - Create `src/types/` with: `api.ts` (`ApiResponseDto<T>`, `PageResult<T>`, `AppError` discriminated union), `auth.ts` (`AuthResponseDto`, `AdminSession`), `restaurant.ts` (full verified DTOs), `order.ts` (`OrderDto`, `OrderStatus` union of 9 values), `delivery.ts` (`DeliveryPartnerDto`), `customer.ts` (`CustomerDto`), `analytics.ts` (`AnalyticsSummaryDto`)
  - Create `src/lib/error-mapper.ts`: maps `AxiosError` to exactly one `AppError` type
  - Create `src/lib/token-utils.ts`: `decodeAdminSession(token)` via manual base64 JWT decode (no external JWT library needed); `isTokenExpired(exp: number)` pure function
  - Create `src/lib/api-response.ts`: `unwrapApiResponse<T>` and `decodePageResult<T>`
  - Target: `src/types/`, `src/lib/error-mapper.ts`, `src/lib/token-utils.ts`, `src/lib/api-response.ts`
  - _Requirements: 16, 17, 18_

  - [ ] 3.1 Unit test: error mapper
    - Network error → `no_connection`; timeout → `timeout`; 401 → `unauthorized`; 429 → `rate_limit`; 5xx → `server`; 4xx → `client` with message; every status maps to exactly one type
    - Target: `src/lib/__tests__/error-mapper.test.ts`

  - [ ] 3.2 Unit test: token utilities
    - Expired exp returns `true`; future exp returns `false`; boundary (exp === now) returns `true`; `decodeAdminSession` extracts all five fields correctly
    - Target: `src/lib/__tests__/token-utils.test.ts`

  - [ ] 3.3 Unit test: pagination utility
    - For any (totalElements ≥ 0, pageSize ≥ 1), `pageCount === Math.ceil(totalElements / pageSize)`
    - Target: `src/utils/__tests__/pagination.test.ts`
    - _Requirements: 17_

- [ ] 4. Implement the networking layer
  - [ ] 4.1 Create the Axios instance and interceptor chain
    - Create `src/lib/api-client.ts`: single Axios instance with `baseURL: import.meta.env.VITE_API_BASE_URL`, `timeout: 15_000`
    - Request interceptor: read `sessionStore.session?.token`; attach `Authorization: Bearer <token>` when path does not start with `/auth/` and token is present
    - Response interceptor: on 401 (non-auth path), call `sessionStore.clearSession()` and `window.location.replace('/login?reason=session_expired')`; map all errors to `AppError` via `error-mapper`
    - Target: `src/lib/api-client.ts`
    - _Requirements: 2, 3, 16, 18_

  - [ ] 4.2 Implement ApiResponse and PageResult decoders
    - `unwrapApiResponse<T>`: asserts `success === true`, returns `data`; throws on `success === false`
    - `decodePageResult<T>`: maps Spring `Page<T>` shape to `PageResult<T>`
    - Target: `src/lib/api-response.ts`
    - _Requirements: 6, 17_

  - [ ] 4.3 Configure TanStack QueryClient
    - Create `src/lib/query-client.ts`: `new QueryClient` with `defaultOptions.queries: { staleTime: 60_000, gcTime: 300_000, retry: 1 }`; export singleton
    - Wrap `src/main.tsx` with `<QueryClientProvider client={queryClient}>`
    - Target: `src/lib/query-client.ts`, `src/main.tsx`
    - _Requirements: 19_

  - [ ] 4.4 Component test: auth header attachment and 401 handling
    - Mock `sessionStore` with a token; assert request header is attached; mock 401 response; assert `clearSession` called and redirect occurs; assert `/auth/login` paths bypass interceptor
    - Target: `src/lib/__tests__/api-client.test.ts`
    - _Requirements: 2, 3, 18_

- [ ] 5. Implement Zustand stores
  - `src/stores/session-store.ts`: `AdminSession | null`, `setSession`, `clearSession`; persist to `localStorage` via `zustand/middleware/persist` with storage key `admin_session`; on persist rehydration, call `isTokenExpired(session.exp)` and clear if expired
  - `src/stores/theme-store.ts`: `ThemeMode`, `setTheme`; persist to `localStorage`
  - `src/stores/ui-store.ts`: `sidebarCollapsed`, `toggleSidebar`, `notificationPanelOpen`, `toggleNotificationPanel`; no persistence
  - Target: `src/stores/`
  - _Requirements: 2, 15, 21_

  - [ ] 5.1 Unit test: session store expiry on rehydration
    - Persist a session with an expired `exp`; reload store; assert `session === null`
    - Target: `src/stores/__tests__/session-store.test.ts`

- [ ] 6. Implement routing and auth guard
  - Create `src/router/index.tsx` with `createBrowserRouter` matching the design route table: `/login`, `/ (AuthGuard) / AppShell / [dashboard, restaurants, restaurants/:id, orders, orders/:id, delivery-partners, delivery-partners/:id, customers, customers/:id, analytics, notifications, settings]`
  - Implement `AuthGuard` as a layout route with a `loader` that reads `sessionStore`, returns `redirect('/login')` when unauthenticated or expired; passes through otherwise
  - Mount router in `src/main.tsx` via `<RouterProvider router={router} />`
  - Target: `src/router/index.tsx`, `src/router/auth-guard.tsx`
  - _Requirements: 2, 3, 18_

  - [ ] 6.1 Component test: AuthGuard redirect
    - No session → redirects to `/login`; expired session → redirects to `/login`; valid session → renders children
    - Target: `src/router/__tests__/auth-guard.test.tsx`

- [ ] 7. Checkpoint — infrastructure complete
  - All tests pass; TypeScript compiles clean; app boots and auth guard redirects unauthenticated requests to login; ask user if questions arise

- [ ] 8. Implement the auth feature
  - [ ] 8.1 Implement auth service and useLogin mutation
    - `src/services/auth.service.ts`: `login(email, password)` calls `POST /auth/login/admin`, unwraps `AuthResponseDto`, returns `AdminSession` (decoded via `decodeAdminSession`)
    - `src/hooks/use-login.ts`: `useMutation` wrapping `auth.service.login`; on success calls `sessionStore.setSession`, then `navigate('/dashboard')`; on error surfaces `AppError`
    - Target: `src/services/auth.service.ts`, `src/hooks/use-login.ts`
    - _Requirements: 1_

  - [ ] 8.2 Implement LoginPage
    - Centered card layout with email + password inputs, "Remember me" checkbox (controls localStorage vs sessionStorage), submit button with loading spinner
    - Zod schema: `z.object({ email: z.string().email(), password: z.string().min(1) })`; `react-hook-form` with `zodResolver`
    - Display inline error for 401 ("Invalid email or password"); display timed-disable message for 429 (60s countdown); block duplicate submit while mutation is pending
    - Target: `src/features/auth/login-page.tsx`
    - _Requirements: 1, 3_

  - [ ] 8.3 Component test: LoginPage
    - Valid submit sends correct payload; 401 shows inline error; 429 disables button with countdown; loading spinner shown while pending; duplicate submit blocked
    - Target: `src/features/auth/__tests__/login-page.test.tsx`
    - _Requirements: 1_

- [ ] 9. Implement the AppShell layout
  - [ ] 9.1 Implement Sidebar
    - Nav links: Dashboard, Restaurants, Orders, Delivery Partners, Customers, Analytics, Notifications, Settings; active link highlighted via `useMatch`; collapsible to icon-only when `uiStore.sidebarCollapsed` is true; responsive collapse below 1024px via `ResizeObserver`; Lucide icons for each section
    - Target: `src/components/layout/sidebar.tsx`
    - _Requirements: 21_

  - [ ] 9.2 Implement Header
    - Breadcrumbs derived from `useMatches()`; notification bell with unread badge (from `uiStore.notificationPanelOpen` + future count); user-menu dropdown (admin name + email from `sessionStore.session`, link to Settings, Logout with `ConfirmDialog`)
    - Logout flow: `ConfirmDialog` → `sessionStore.clearSession()` → `navigate('/login')`
    - Session-expiry banner: shown when `isTokenExpired` returns true within 5 minutes of exp
    - Target: `src/components/layout/header.tsx`
    - _Requirements: 4, 18_

  - [ ] 9.3 Implement AppShell and integrate into router
    - `AppShell` combines Sidebar + Header + `<Outlet>`; handles responsive sidebar state; 3-column grid on desktop (`sidebar | header+content`), stacked on mobile
    - Target: `src/components/layout/app-shell.tsx`
    - _Requirements: 21_

- [ ] 10. Implement shared component catalog
  - [ ] 10.1 DataTable
    - Generic `DataTable<TData>` built on TanStack Table v8 + `@tanstack/react-virtual` for virtual row rendering when rows > 50; accepts `columns`, `data`, `pagination`, `onPaginationChange`, `rowCount`, `isLoading`, `isError`, `onRetry`, optional `sorting`/`onSortingChange`, optional `onRowClick`
    - Renders `SkeletonTable` when `isLoading`; renders `ErrorState` when `isError`; renders `EmptyState` when `data.length === 0`; renders pagination controls (prev/next/page-size selector) with total record count
    - Target: `src/components/ui/data-table.tsx`
    - _Requirements: 6, 9, 11, 12, 17_

  - [ ] 10.2 StatCard
    - Renders metric value, label, optional trend badge (up/down arrow + percentage), optional loading skeleton, optional error with retry, optional `PendingFeature` overlay
    - Target: `src/components/ui/stat-card.tsx`
    - _Requirements: 5_

  - [ ] 10.3 PendingFeature
    - Wrapper that `aria-disables` all interactive children; renders a bottom badge with the expected endpoint string and a gap reference tooltip; accepts `endpoint: string` and `gap: string` props
    - Target: `src/components/ui/pending-feature.tsx`
    - _Requirements: 5, 8, 9, 10, 11, 12, 13_

  - [ ] 10.4 Supporting widgets
    - `StatusBadge` — colored chip per `OrderStatus` value (each status has a distinct Tailwind color class)
    - `ConfirmDialog` — modal with title, description, confirm/cancel buttons; blocks confirm while pending
    - `PageHeader` — title + optional subtitle + optional action slot
    - `ErrorState` — icon + message + retry button
    - `EmptyState` — icon + message + optional CTA
    - `SkeletonTable` / `SkeletonCards` — Tailwind `animate-pulse` placeholder rows/cards
    - Target: `src/components/ui/`
    - _Requirements: 5, 9, 16_

  - [ ] 10.5 Component test: DataTable
    - Renders skeleton rows when loading; renders error state when error + calls onRetry; renders empty state on empty data; pagination controls trigger correct page change; sort header click fires sort callback; virtual rows render for 200-row dataset
    - Target: `src/components/ui/__tests__/data-table.test.tsx`

  - [ ] 10.6 Component test: PendingFeature
    - All interactive children within `PendingFeature` are `aria-disabled`; endpoint badge is visible; gap tooltip renders on hover
    - Target: `src/components/ui/__tests__/pending-feature.test.tsx`

- [ ] 11. Implement the restaurant feature (verified endpoints)
  - [ ] 11.1 Implement restaurant service and hooks
    - `src/services/restaurant.service.ts`: `getRestaurants(params)` calls `GET /restaurants`, unwraps `ApiResponse<Page<RestaurantDto>>`; `getRestaurantById(id)` calls `GET /restaurants/{id}`; `searchRestaurants(params)` calls `GET /restaurants/search`
    - `src/hooks/use-restaurants.ts`: `useRestaurants(params)` with query key `['restaurants', 'list', params]`, `keepPreviousData`, 400ms debounce on filter changes via `useDeferredValue`; `useRestaurantById(id)` with key `['restaurants', 'detail', id]`
    - Target: `src/services/restaurant.service.ts`, `src/hooks/use-restaurants.ts`
    - _Requirements: 6, 7_

  - [ ] 11.2 Implement RestaurantListPage
    - `DataTable` with columns: Name, City, Categories (comma-joined), Status (open/closed `StatusBadge`), Created Date, Actions (View button)
    - Filter bar: City text input (debounced 400ms), Category select (populated from unique categories in loaded data — Gap 11 from customer app), Search keyword input (switches to `/restaurants/search` endpoint when non-empty)
    - Page-size selector (10/20/50); pagination controls showing total count; server-side pagination
    - `PageHeader` with title "Restaurants" and total count
    - Target: `src/features/restaurants/restaurant-list-page.tsx`, `src/features/restaurants/restaurant-filters.tsx`
    - _Requirements: 6_

  - [ ] 11.3 Implement RestaurantDetailPage
    - Two-column layout (60/40): left column has restaurant info card (name, city, address, phone, coordinates, open/closed, image); right column has tabbed menu (one tab per category, each showing item cards with price, availability, vegetarian badge)
    - Restaurant status toggle wrapped in `<PendingFeature endpoint="PATCH /admin/restaurants/{id}/status" gap="Gap 3" />`; displays current status as read-only badge
    - Back button navigates to restaurant list preserving filter state via `searchParams`
    - Target: `src/features/restaurants/restaurant-detail-page.tsx`
    - _Requirements: 7, 8_

  - [ ] 11.4 Component tests: restaurant feature
    - List renders skeleton on load; renders rows on success; city filter changes query params; search switches endpoint; row click navigates to detail; error state renders with retry
    - Detail renders restaurant info and menu tabs; status toggle is `aria-disabled` inside `PendingFeature`; 404 shows not-found message
    - Target: `src/features/restaurants/__tests__/`
    - _Requirements: 6, 7, 8_

- [ ] 12. Implement the dashboard feature (Gap 2 — placeholder UI)
  - Implement `src/services/analytics.service.ts` with a placeholder implementation returning typed mock data: `getSummary()` returns a mock `DashboardSummaryDto`; `getOrdersPerDay(range)` returns mock `RevenuePointDto[]`; all methods are documented with `// TODO: Gap 2 — replace with GET /admin/analytics/summary`
  - Build `DashboardPage` with a responsive 4-column stat-card grid (Total Orders Today, Total Revenue Today, Active Delivery Partners, Total Restaurants), an `OrdersLineChart` (7-day orders), a `RecentOrdersTable` (10 rows, gap-backed), and a `TopRestaurantsCard` (gap-backed)
  - All gap-backed cards are wrapped in `<PendingFeature>`; the real metric values are zeroed/mocked but the full UI is present and functional
  - Build `OrdersLineChart` and `StatusPieChart` as Recharts `<LineChart>` / `<PieChart>` components accepting typed props; they render normally on mock data and will accept real data when the service is wired up
  - Target: `src/features/dashboard/dashboard-page.tsx`, `src/components/charts/`, `src/services/analytics.service.ts`
  - _Requirements: 5_

  - [ ] 12.1 Component test: DashboardPage
    - Stat cards render with loading skeletons while data fetches; render mock values on success; each card shows `PendingFeature` badge; error state on service failure shows retry per-card
    - Target: `src/features/dashboard/__tests__/dashboard-page.test.tsx`

- [ ] 13. Implement the order management feature (Gap 4 — placeholder UI)
  - Implement `src/services/order.service.ts` with placeholder: `getOrders(params)` returns typed mock `PageResult<OrderDto>`; `getOrderById(id)` returns mock `OrderDto`; `overrideOrderStatus(id, status, reason)` returns void; all documented with `// TODO: Gap 4`
  - Build `OrderListPage`: `DataTable` with columns (Order ID truncated, Customer Name, Restaurant Name, Amount, Status `StatusBadge`, Created Date); status filter chips (All + each `OrderStatus` value); date-range picker; free-text search; all wrapped in `<PendingFeature endpoint="GET /admin/orders" gap="Gap 4" />`
  - Build `OrderDetailPage`: order info (items table, pricing breakdown: subtotal/fee/tax/total, delivery address, status history); "Override Status" action wrapped in `<PendingFeature endpoint="PATCH /admin/orders/{id}/status" gap="Gap 4" />`
  - Build `OrderStatusOverrideDialog`: dropdown for target status (9 options), required reason textarea (min 10 chars, Zod validated), confirmation summary card, submit/cancel
  - Target: `src/features/orders/`
  - _Requirements: 9, 10_

  - [ ] 13.1 Component test: order status override dialog
    - Submit disabled when reason < 10 chars; Zod error shown for blank reason; confirmation summary shows current + target status; dialog closes on cancel; mutation called on confirm
    - Target: `src/features/orders/__tests__/order-status-override-dialog.test.tsx`

- [ ] 14. Implement the delivery partner management feature (Gap 5 — placeholder UI)
  - Implement `src/services/delivery.service.ts` with placeholder: `getDeliveryPartners(params)` returns mock `PageResult<DeliveryPartnerDto>`; `getDeliveryPartnerById(id)` returns mock `DeliveryPartnerDto`; `updatePartnerStatus(id, suspended)` returns void; all `// TODO: Gap 5`
  - Build `DeliveryPartnerListPage`: `DataTable` with columns (Name, Email, Phone, Online Status chip, Availability chip, Assignment indicator, Total Deliveries, Joined Date); filter bar (online-only toggle, assigned-only toggle); all wrapped in `<PendingFeature endpoint="GET /admin/delivery-partners" gap="Gap 5" />`
  - Build `DeliveryPartnerDetailPage`: profile card, vehicle info, current assignment card (if assigned), recent deliveries table, earnings summary; Suspend/Activate toggle wrapped in `<PendingFeature endpoint="PATCH /admin/delivery-partners/{id}/status" gap="Gap 5" />`
  - Target: `src/features/delivery-partners/`
  - _Requirements: 11_

- [ ] 15. Implement the customer management feature (Gap 6 — placeholder UI)
  - Implement `src/services/customer.service.ts` with placeholder: `getCustomers(params)` returns mock `PageResult<CustomerDto>`; `getCustomerById(id)` returns mock `CustomerDto`; `updateCustomerStatus(id, suspended)` returns void; all `// TODO: Gap 6`
  - Build `CustomerListPage`: `DataTable` with columns (Name, Email, Phone, Total Orders, Total Spend, Status chip, Joined Date); search field; all wrapped in `<PendingFeature endpoint="GET /admin/customers" gap="Gap 6" />`
  - Build `CustomerDetailPage`: profile card, order history table; Suspend/Activate toggle wrapped in `<PendingFeature endpoint="PATCH /admin/customers/{id}/status" gap="Gap 6" />`
  - Target: `src/features/customers/`
  - _Requirements: 12_

- [ ] 16. Implement the analytics feature (Gap 7 — placeholder UI)
  - `AnalyticsPage` with full chart layout: revenue line chart, top-restaurants bar chart, order-status pie chart, delivery performance line chart; date-range presets (Today, 7d, 30d, Custom with date pickers)
  - All charts wrapped in `<PendingFeature endpoint="GET /admin/analytics/revenue" gap="Gap 7" />`; charts render correctly on mock data from `analytics.service.ts` placeholder
  - Build `RevenueLineChart`, `TopRestaurantsBarChart`, `StatusPieChart`, `DeliveryPerformanceChart` as pure Recharts components accepting typed data props; zero business logic inside chart components
  - Target: `src/features/analytics/`, `src/components/charts/`
  - _Requirements: 13_

- [ ] 17. Implement the notifications feature (Gap 8 — placeholder UI)
  - Build `NotificationsPage`: list of `AppNotification` items in reverse-chronological order; each item has type badge, message, timestamp, and an entity link; "Mark all read" action clears unread count; empty state when no notifications
  - Notifications stored in `notificationStore` (Zustand, in-memory for now); the bell badge in `Header` reads the unread count from this store
  - All notifications content wrapped in `<PendingFeature endpoint="GET /admin/notifications" gap="Gap 8" />` with a note that the notification service is currently a backend stub
  - Target: `src/features/notifications/`, `src/stores/notification-store.ts`
  - _Requirements: 14_

- [ ] 18. Implement the settings feature
  - Build `SettingsPage` with two sections: "Account" (admin name, email, role, phone — read from `sessionStore.session`; editing disabled with `PendingFeature` on save — `// TODO: Gap 9`) and "Preferences" (theme selector: Light/Dark/System radio group, persisted via `themeStore`)
  - Theme change applies immediately via `ThemeProvider` without page reload
  - Target: `src/features/settings/settings-page.tsx`
  - _Requirements: 15_

  - [ ] 18.1 Component test: settings page
    - Theme radio group changes apply class on `<html>` immediately; account fields are read-only; save button is `aria-disabled` inside `PendingFeature`
    - Target: `src/features/settings/__tests__/settings-page.test.tsx`

- [ ] 19. Accessibility audit and fixes
  - Add `@axe-core/react` in development mode to flag violations as console errors; fix all flagged issues across all pages
  - Audit every data table: verify `<table>`, `<thead>`, `<th scope="col">`, `<tbody>` semantic HTML is used
  - Audit every form: verify every input has an associated `<label>`; verify every icon-only button has `aria-label`
  - Verify keyboard navigation: Tab navigates all interactive controls in DOM order; focus rings are visible with the current Tailwind `ring` utilities
  - Add `aria-live="polite"` regions for async operation completion messages (mutation success/error toasts)
  - Target: all `src/features/` and `src/components/` files
  - _Requirements: 20_

- [ ] 20. Performance optimisations
  - Verify route-level code splitting: each feature route uses `React.lazy` + `Suspense` so the initial bundle does not include all feature code; verify with `vite build --mode production` bundle analyser
  - Add virtual row rendering to `DataTable` for datasets > 50 rows using `@tanstack/react-virtual` (already scaffolded in task 10.1); verify no performance regression in restaurant list with 200 mock rows
  - Verify TanStack Query deduplication: two components on the same page using `useRestaurants` with the same params produce exactly one MSW request intercept
  - Verify `keepPreviousData` behaviour: navigating from page 1 to page 2 does not flash an empty table
  - Target: `src/features/*/`, `src/components/ui/data-table.tsx`
  - _Requirements: 19_

- [ ] 21. Filter builder and format utilities
  - `src/utils/filter-builder.ts`: `buildFilterParams(filters: Record<string, unknown>)` — produces `URLSearchParams` omitting keys with `undefined`, `null`, or empty-string values; pure function
  - `src/utils/format.ts`: `formatCurrency(value: string, locale = 'en-IN', currency = 'INR')` using `Intl.NumberFormat`; `formatDate(iso: string)` using `date-fns`; `formatRelativeTime(iso: string)` for "2 hours ago" style; `truncateId(uuid: string, length = 8)` for table display
  - Target: `src/utils/filter-builder.ts`, `src/utils/format.ts`
  - _Requirements: 9, 13_

  - [ ] 21.1 Unit test: filter builder
    - `undefined` / `null` / empty-string values are omitted; non-empty values are included; result is a valid `URLSearchParams`
    - Target: `src/utils/__tests__/filter-builder.test.ts`

- [ ] 22. End-to-end integration test
  - Build a Vitest integration test using MSW that runs the full verified-endpoint flow:
    1. Mount app at `/login`; submit valid credentials (MSW: `POST /auth/login/admin` → mock `AuthResponse`)
    2. Assert redirect to `/dashboard`; assert admin name appears in Header
    3. Navigate to `/restaurants`; assert MSW receives `GET /restaurants?page=0&size=20`; assert restaurant rows render
    4. Enter search keyword; assert MSW receives `GET /restaurants/search?keyword=...`
    5. Click first restaurant; assert MSW receives `GET /restaurants/{id}`; assert detail renders
    6. Assert restaurant status toggle is `aria-disabled` (gap placeholder active)
    7. Mock a 401 response on any authenticated request; assert `clearSession` called and redirect to `/login`
  - Target: `src/test/integration/full-flow.test.tsx`
  - _Requirements: 1–21_

- [ ] 23. Final checkpoint
  - All unit, component, and integration tests pass; `npm run build` exits 0; TypeScript strict mode zero errors; `axe-core` zero violations in development mode; all gap features display `PendingFeature` banners with correct endpoint and gap references; ask user if questions arise

## Phase: Map-Based Fleet & Order Monitoring (Google Maps Integration)
- [ ] 24. Integrate Google Maps & Live WebSocket Tracking
  - Add `@react-google-maps/api` and `react-stomp` (or similar STOMP client).
  - Implement `FleetTrackingPage` showing a large Google Map.
  - Subscribe to Tracking Service WebSockets (`/ws/tracking`) to receive live rider locations.
  - Render all online delivery partners as markers on the map, updating their position smoothly based on WebSocket events.
  - Connect to the Directions API to show the route between rider and customer when viewing an active order.
  - Target: `src/features/fleet-tracking/`
  - _Requirements: Google Maps, STOMP WebSocket_
