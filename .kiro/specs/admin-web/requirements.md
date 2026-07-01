# Requirements Document — Admin Web Dashboard

## Introduction

This document specifies the requirements for the **Admin Web Dashboard**, the administrator-facing React web application of the existing Food Delivery Platform. The Admin Dashboard is one of three frontend clients alongside the Customer App and the Delivery Partner App.

The application is built with React 18 and TypeScript, using TanStack Query v5 for server state, Zustand for client state, React Router v6 for routing, Axios for networking, Tailwind CSS and shadcn/ui for UI, Recharts for analytics charts, React Hook Form and Zod for forms, and TanStack Table v8 for data tables. The application targets the directory `frontend/admin-web`.

The platform backend exists as a set of Spring Boot microservices behind a Spring Cloud Gateway. The gateway enforces JWT authentication on all routes except `/auth/**` and injects identity headers (`X-User-*`) downstream. Administrator tokens carry the `ADMIN` role. The admin login endpoint is `POST /auth/login/admin`.

**Backend reality:** The admin role exists in the system but the backend exposes very few admin-specific endpoints. Most admin capabilities (dashboard analytics, user management, order management, delivery partner management, revenue analytics, system health) have no existing backend endpoint. Every requirement in this document maps to an existing endpoint where one exists. All others reference the **Backend Gaps & Resolution Strategy** section.

This is a requirements document only. It does not contain design or implementation detail.

---

## Glossary

### System Components

- **Admin_Dashboard**: The complete React admin web application described by this document.
- **Auth_Module**: Login, logout, session persistence, and credential management for administrators.
- **Session_Manager**: Stores, retrieves, attaches, and clears the admin JWT and derived `AdminSession` (adminId, email, role, name, exp).
- **Network_Layer**: Axios-based client responsible for HTTP requests, JWT attachment, timeout/cancellation, and error surfacing.
- **Dashboard_Module**: Landing screen showing key platform metrics.
- **Restaurant_Module**: Browse, search, view, and manage restaurants across the platform.
- **Order_Module**: View and manage all customer orders across the platform.
- **Delivery_Module**: View and manage delivery partners and active assignments.
- **User_Module**: View and manage customer accounts.
- **Analytics_Module**: Revenue, delivery, and operational analytics with charts.
- **Settings_Module**: Admin preferences, theme, and account settings.
- **Notification_Module**: System alert display and notification history.

### Domain Terms

- **API_Gateway**: The Spring Cloud Gateway at the backend base URL; enforces JWT on non-`/auth/**` routes.
- **JWT**: The bearer token returned on successful admin login; carries adminId, email, role (ADMIN), name, phone, exp.
- **AdminSession**: Decoded JWT payload: `{adminId, email, role, name, phone, exp}`.
- **ApiResponse**: The restaurant-service response envelope `{success: boolean, message: string, data: T}`.
- **PageResponse**: Spring `Page<T>` payload: `{content[], number, size, totalElements, totalPages, last, first}`.
- **OrderStatus**: The nine backend order lifecycle values: `PENDING_PAYMENT`, `CONFIRMED`, `PREPARING`, `READY_FOR_PICKUP`, `DELIVERY_PARTNER_ASSIGNED`, `OUT_FOR_DELIVERY`, `DELIVERED`, `CANCELLED`, `FAILED`.
- **Backend_Gap**: A required admin capability with no existing backend endpoint, tracked in the Backend Gaps section.
- **AuthResponse**: Backend DTO: `{token, userId, fullName, email, role}`.

### Backend Endpoint Reference (verified)

- `POST /auth/login/admin` — authenticate an admin; request: `{email, password}`; response: `AuthResponse`; rate limited 5/min/IP.
- `GET /restaurants?city=&category=&page=&size=` — paginated public restaurant list.
- `GET /restaurants/{id}` — public restaurant detail with nested categories and items.
- `GET /restaurants/search?keyword=&page=&size=` — paginated public restaurant search.

> All other admin capabilities (order management, user management, delivery partner management, analytics, system health) are **Backend Gaps**.

---

## Requirements

### Requirement 1: Admin Login

**User Story:** As a platform administrator, I want to log in with my email and password, so that I can access the admin dashboard.

#### Acceptance Criteria

1. WHEN an admin submits the login form with a valid email and a non-empty password, THE Auth_Module SHALL send an authentication request to `POST /auth/login/admin`.
2. WHEN the authentication request returns HTTP 200, THE Session_Manager SHALL persist the returned JWT in `localStorage` (or `sessionStorage` per setting), SHALL decode `AdminSession`, and SHALL redirect to the dashboard home.
3. IF the authentication request returns HTTP 401, THEN THE Auth_Module SHALL display "Invalid email or password" and SHALL NOT persist any token.
4. IF the authentication request returns HTTP 429, THEN THE Auth_Module SHALL display "Too many login attempts. Please wait." and SHALL disable the submit button for 60 seconds.
5. WHILE the authentication request is in progress, THE Auth_Module SHALL display a loading spinner on the submit button and SHALL prevent duplicate submissions.
6. THE Auth_Module SHALL display a "Remember me" toggle; when checked, the JWT SHALL be persisted in `localStorage`; when unchecked, in `sessionStorage`.

**Backend mapping:** `POST /auth/login/admin` (rate limited 5/min/IP → 429; response: `AuthResponse{token, userId, fullName, email, role}`).

### Requirement 2: Session Persistence and Token Attachment

**User Story:** As an administrator, I want my session to persist across page refreshes, so that I do not need to log in every time I navigate.

#### Acceptance Criteria

1. WHEN the Admin_Dashboard loads AND a stored non-expired JWT is present, THE Session_Manager SHALL load the `AdminSession` and render the authenticated layout.
2. WHEN the Admin_Dashboard loads AND no valid JWT is present, THE Session_Manager SHALL redirect to the login page.
3. WHEN the Network_Layer issues a request to any path other than `/auth/**`, THE Network_Layer SHALL attach the stored JWT as an `Authorization: Bearer <token>` header.
4. THE Session_Manager SHALL expose the decoded `AdminSession` to all modules for display (name, email, role).
5. WHERE a stored JWT is expired based on its `exp` claim, THE Session_Manager SHALL treat the session as unauthenticated and SHALL redirect to the login page.

**Backend mapping:** API_Gateway JWT filter enforces `Authorization: Bearer <token>`. Token refresh is a Backend_Gap — see Gap 1.

### Requirement 3: Session Expiry and Unauthorized Response Handling

**User Story:** As an admin whose session has expired, I want the app to handle the expiry gracefully and route me back to login.

#### Acceptance Criteria

1. IF any authenticated request returns HTTP 401, THEN THE Session_Manager SHALL clear the stored JWT and SHALL redirect to the login page with an "Your session has expired" message.
2. THE Network_Layer SHALL expose a single Axios response-interceptor for 401 handling so that a future token-refresh flow can be introduced without restructuring any request code.

**Backend mapping:** BACKEND GAP — see Gap 1 (no refresh endpoint; current behavior: clear → redirect to login).

### Requirement 4: Logout

**User Story:** As an admin, I want to log out securely, so that my session is not accessible after I leave.

#### Acceptance Criteria

1. WHEN an admin clicks Logout, THE Session_Manager SHALL delete the JWT from storage and SHALL redirect to the login page, clearing the navigation history.
2. THE Auth_Module SHALL require a confirmation dialog before logging out.

**Backend mapping:** Local JWT deletion (stateless; no server-side revocation — see Gap 1).

### Requirement 5: Dashboard Overview

**User Story:** As an admin, I want a dashboard home page with key platform metrics, so that I can assess the platform's health at a glance.

#### Acceptance Criteria

1. WHEN the Dashboard_Module loads, it SHALL display metric cards for: total orders today, total revenue today, active delivery partners, total restaurants, and orders by status breakdown.
2. THE Dashboard_Module SHALL display a line chart of orders per day for the last 7 days.
3. THE Dashboard_Module SHALL display a recent-orders feed showing the 10 most recent orders with their status, restaurant, and amount.
4. THE Dashboard_Module SHALL display a top-restaurants card showing the 5 restaurants with the most orders this week.
5. WHEN the admin refreshes the dashboard, ALL metric cards SHALL reload their data.
6. WHILE dashboard data is loading, THE Dashboard_Module SHALL display skeleton placeholder cards.
7. IF a metric endpoint returns an error, THE Dashboard_Module SHALL display an error state for that card with a retry control independently of other cards.

**Backend mapping:** BACKEND GAP — see Gap 2. All dashboard metrics require new backend analytics endpoints.

### Requirement 6: Restaurant List

**User Story:** As an admin, I want to browse all restaurants on the platform, so that I can oversee restaurant listings.

#### Acceptance Criteria

1. WHEN the Restaurant_Module loads, it SHALL request the first page of restaurants from `GET /restaurants` with a page size of 20.
2. THE Restaurant_Module SHALL display each restaurant's name, city, cuisine categories, open/closed status, and creation date in a sortable data table.
3. WHEN the admin applies a city filter, THE Restaurant_Module SHALL include the `city` query parameter; when applying a category filter, it SHALL include the `category` query parameter.
4. WHEN the admin navigates to a subsequent page, THE Restaurant_Module SHALL request the corresponding page via `GET /restaurants?page=N&size=20`.
5. WHEN the admin enters a search keyword and pauses for 400ms, THE Restaurant_Module SHALL switch to `GET /restaurants/search?keyword=&page=&size=20`.
6. WHEN a search is active and the admin clears the keyword, THE Restaurant_Module SHALL return to the standard paginated list.
7. WHEN the list is empty, THE Restaurant_Module SHALL display an empty-state message.
8. WHILE data is loading, THE Restaurant_Module SHALL display a skeleton table.

**Backend mapping:** `GET /restaurants` (paginated, filters: city, category) and `GET /restaurants/search` (keyword, paginated). Both are public endpoints accessible with admin JWT.

### Requirement 7: Restaurant Detail View

**User Story:** As an admin, I want to view a restaurant's full details and menu, so that I can audit its content.

#### Acceptance Criteria

1. WHEN the admin selects a restaurant from the list, THE Restaurant_Module SHALL request `GET /restaurants/{id}` and display the full restaurant detail.
2. THE Restaurant_Module SHALL display restaurant information: name, description, city, address, phone, cuisine categories, open/closed status, operating hours, ratings, and image.
3. THE Restaurant_Module SHALL display the restaurant's full menu grouped by category, showing each item's name, description, price, availability, and vegetarian status.
4. WHILE the restaurant detail is loading, THE Restaurant_Module SHALL display a skeleton detail layout.
5. IF the request returns HTTP 404, THE Restaurant_Module SHALL display a "Restaurant not found" message and a back control.

**Backend mapping:** `GET /restaurants/{id}` (public; `RestaurantResponse` with nested categories and items).

### Requirement 8: Restaurant Status Management

**User Story:** As an admin, I want to be able to suspend or activate a restaurant, so that I can enforce platform policies.

#### Acceptance Criteria

1. THE Restaurant_Module SHALL display an "Active / Suspended" status toggle for each restaurant in the detail view.
2. WHEN an admin changes a restaurant's status, THE Restaurant_Module SHALL send the appropriate status update request.
3. WHEN the status change request succeeds, THE Restaurant_Module SHALL update the displayed status without a full page reload.
4. THE Restaurant_Module SHALL display a confirmation dialog before any status change.
5. WHERE the admin-specific status endpoint is unavailable, THE Restaurant_Module SHALL present the status control in a disabled state with a "Backend feature pending" label.

**Backend mapping:** BACKEND GAP — see Gap 3. The existing `PATCH /restaurants/{id}/status` endpoint requires `RESTAURANT_OWNER` role, not `ADMIN`. A new admin-scoped endpoint is required.

### Requirement 9: Order Management

**User Story:** As an admin, I want to see all orders across the platform, so that I can monitor order fulfilment and investigate issues.

#### Acceptance Criteria

1. WHEN the Order_Module loads, it SHALL display a paginated table of all platform orders sorted by creation time descending.
2. Each order row SHALL display: order ID, customer name, restaurant name, total amount, current `OrderStatus`, and creation timestamp.
3. THE Order_Module SHALL provide status filter chips for each of the nine `OrderStatus` values plus an "All" option.
4. THE Order_Module SHALL provide a date-range filter (from/to) and a free-text search by order ID or customer name.
5. WHEN the admin selects an order, THE Order_Module SHALL display an order detail panel showing all order items, pricing breakdown (subtotal, delivery fee, tax, total), delivery address, and the full status history.
6. WHERE admin order endpoints are unavailable, THE Order_Module SHALL display a "Backend feature pending" placeholder with the expected endpoint documented.

**Backend mapping:** BACKEND GAP — see Gap 4. `GET /orders/my-orders` is `CUSTOMER`-role only and returns only the authenticated customer's orders. A new `GET /admin/orders` endpoint with pagination and filtering is required.

### Requirement 10: Order Status Override

**User Story:** As an admin, I want to manually override an order's status in exceptional circumstances, so that stuck orders can be resolved.

#### Acceptance Criteria

1. THE Order_Module SHALL provide a "Override Status" action on each order detail panel.
2. WHEN an admin selects a new status and confirms, THE Order_Module SHALL send the status update request.
3. THE Order_Module SHALL require a mandatory reason field (minimum 10 characters) for every status override; the reason SHALL be included in the request body.
4. THE Order_Module SHALL display a confirmation dialog summarising the current status, the target status, and the reason before submitting.
5. WHERE the admin order-status override endpoint is unavailable, the action SHALL be disabled with a "Backend feature pending" label.

**Backend mapping:** BACKEND GAP — see Gap 4. No admin order-status endpoint exists.

### Requirement 11: Delivery Partner Management

**User Story:** As an admin, I want to see all delivery partners and their current status, so that I can monitor delivery operations.

#### Acceptance Criteria

1. WHEN the Delivery_Module loads, it SHALL display a paginated table of all delivery partners with: name, email, phone, online/offline status, current assignment, total completed deliveries, and registration date.
2. THE Delivery_Module SHALL provide filters for: online-only, offline-only, and currently assigned.
3. WHEN the admin selects a delivery partner, THE Delivery_Module SHALL display a detail panel showing: profile info, vehicle details, current assignment (if any), recent delivery history, and earnings summary.
4. THE Delivery_Module SHALL display a live map view showing the positions of all currently online partners (requires partner location data).
5. THE Delivery_Module SHALL provide a "Suspend / Activate" action for each partner.
6. WHERE delivery partner management endpoints are unavailable, THE Delivery_Module SHALL display a "Backend feature pending" placeholder.

**Backend mapping:** BACKEND GAP — see Gap 5. No admin delivery partner list or management endpoint exists.

### Requirement 12: Customer Management

**User Story:** As an admin, I want to view all customer accounts, so that I can manage the customer base.

#### Acceptance Criteria

1. WHEN the User_Module loads, it SHALL display a paginated table of all customer accounts with: name, email, phone, registration date, total orders, and total spend.
2. THE User_Module SHALL provide a search field (by name or email) and filters for: active, suspended.
3. WHEN the admin selects a customer, THE User_Module SHALL display a detail panel with profile info and the customer's order history.
4. THE User_Module SHALL provide a "Suspend / Activate" action for each customer.
5. WHERE customer management endpoints are unavailable, THE User_Module SHALL display a "Backend feature pending" placeholder.

**Backend mapping:** BACKEND GAP — see Gap 6. No user list or management endpoint exists.

### Requirement 13: Revenue and Platform Analytics

**User Story:** As an admin, I want to see revenue trends and platform analytics, so that I can understand business performance.

#### Acceptance Criteria

1. WHEN the Analytics_Module loads, it SHALL display a revenue line chart for the selected date range (daily granularity, default last 30 days).
2. THE Analytics_Module SHALL display total revenue, total orders, average order value, and average delivery time for the selected period.
3. THE Analytics_Module SHALL display a top-restaurants-by-revenue bar chart (top 10).
4. THE Analytics_Module SHALL display an order-status distribution pie chart.
5. THE Analytics_Module SHALL display a delivery performance chart: average time from assignment to delivery per day.
6. THE Analytics_Module SHALL support date-range selection with presets: Today, Last 7 days, Last 30 days, Custom.
7. WHERE analytics endpoints are unavailable, THE Analytics_Module SHALL display "Backend feature pending" placeholder charts with documented expected endpoints.

**Backend mapping:** BACKEND GAP — see Gap 7. No analytics or revenue aggregation endpoint exists.

### Requirement 14: Notification Center

**User Story:** As an admin, I want to see system alerts and notifications, so that I stay informed about platform events.

#### Acceptance Criteria

1. WHEN the Notification_Module renders the notification bell, it SHALL display an unread count badge.
2. WHEN the admin opens the notifications panel, it SHALL display all system notifications in reverse chronological order.
3. Each notification SHALL display: type, message, timestamp, and a link to the relevant entity (order, restaurant, partner).
4. WHEN the admin marks all as read, the unread badge SHALL clear.
5. WHILE no backend notification endpoint is available, THE Notification_Module SHALL display client-side demo alerts with a "Backend feature pending" banner.

**Backend mapping:** BACKEND GAP — see Gap 8 (notification service is a stub).

### Requirement 15: Admin Profile and Account Settings

**User Story:** As an admin, I want to view and update my account settings, so that I can manage my admin profile.

#### Acceptance Criteria

1. WHEN the Settings_Module opens the profile section, it SHALL display the admin's full name, email, role, and phone sourced from the `AdminSession`.
2. WHERE profile editing is available, the save action SHALL send the update to the backend.
3. WHERE profile editing is not available, THE Settings_Module SHALL display the fields as read-only with a "Backend feature pending" label.
4. THE Settings_Module SHALL allow the admin to change the UI theme (light/dark/system) and persist the choice to `localStorage`.

**Backend mapping:** Profile from JWT `AdminSession`. Profile edit endpoint is a Backend_Gap — see Gap 9.

---

## Cross-Cutting and Non-Functional Requirements

### Requirement 16: Networking and Error Handling

**User Story:** As an admin, I want the dashboard to handle network and server errors clearly, so that I always know the state of any operation.

#### Acceptance Criteria

1. IF a request fails due to no network connectivity, THEN the affected module SHALL display a "No connection" message with a retry control.
2. IF a request returns HTTP 5xx, THEN the affected module SHALL display a "Server error" message with a retry control.
3. IF a request returns HTTP 4xx (other than 401), THEN the affected module SHALL display the server-provided error message.
4. THE Network_Layer SHALL apply a 15-second timeout to all requests.
5. WHILE a data request is in progress, the requesting module SHALL display a loading state (skeleton, spinner, or disabled button).
6. WHEN a data request returns an empty result set, the requesting module SHALL display an empty state distinct from the error state.
7. THE Network_Layer SHALL cancel in-flight requests when the component that issued them unmounts.

**Backend mapping:** Applies to all verified endpoints.

### Requirement 17: Pagination and Data Tables

**User Story:** As an admin, I want consistent pagination and sortable data tables across all list screens, so that I can find and sort any data efficiently.

#### Acceptance Criteria

1. All data tables SHALL support server-side pagination with page-size options of 10, 20, and 50.
2. All data tables SHALL display the current page number, total pages, and total record count.
3. Columns that support sorting SHALL display a sort-direction indicator and SHALL trigger a server request with the appropriate sort parameter on click.
4. THE Network_Layer SHALL debounce filter changes by 400ms before issuing a new request.
5. ALL paginated list data models SHALL satisfy a round-trip property: `parsePageResponse(serialisePageResponse(page))` yields an equivalent object.

**Backend mapping:** `GET /restaurants` and `GET /restaurants/search` use Spring `Pageable`; future admin endpoints must support the same pagination contract.

### Requirement 18: Security

**User Story:** As an admin, I want my credentials and session handled securely, so that the admin account cannot be easily compromised.

#### Acceptance Criteria

1. THE Session_Manager SHALL never log the JWT value or password to the browser console.
2. WHEN attaching the JWT to a request, THE Network_Layer SHALL enforce HTTPS only.
3. THE Admin_Dashboard SHALL protect all routes under an auth guard that redirects unauthenticated requests to the login page.
4. THE Admin_Dashboard SHALL display a session-expiry warning banner when the stored JWT is within 5 minutes of expiry.

**Backend mapping:** JWT enforced by API_Gateway; token issued by `POST /auth/login/admin`.

### Requirement 19: Performance

**User Story:** As an admin working with large datasets, I want the dashboard to load quickly and remain responsive.

#### Acceptance Criteria

1. THE Admin_Dashboard SHALL use TanStack Query's stale-while-revalidate caching so that navigating back to a visited page displays cached data immediately while a background refresh runs.
2. All large data table columns SHALL use virtual row rendering (`@tanstack/react-virtual`) when the visible row count exceeds 50.
3. THE Admin_Dashboard SHALL code-split each route so that the initial bundle size does not include code for non-visited pages.
4. All chart data requests SHALL be deduplicated by TanStack Query so that multiple chart components requesting the same endpoint result in only one HTTP call.

**Backend mapping:** Not applicable (client-side caching/rendering strategy).

### Requirement 20: Accessibility

**User Story:** As an admin who relies on keyboard navigation or assistive technology, I want the dashboard to be fully accessible.

#### Acceptance Criteria

1. All interactive controls SHALL be keyboard-navigable and SHALL have visible focus indicators.
2. All data tables SHALL use `<table>`, `<thead>`, `<tbody>`, `<th scope>` semantic HTML.
3. All form inputs SHALL have associated `<label>` elements.
4. All icon-only buttons SHALL have `aria-label` attributes.
5. THE Admin_Dashboard SHALL support screen-reader announcements for route changes and async operation completions.

**Backend mapping:** Not applicable.

### Requirement 21: Responsiveness

**User Story:** As an admin accessing the dashboard on different screen sizes, I want the layout to adapt correctly.

#### Acceptance Criteria

1. THE Admin_Dashboard SHALL render a collapsed sidebar (icon-only) on screens narrower than 1024px and an expanded sidebar on screens at 1024px or wider.
2. Data tables SHALL become horizontally scrollable on screens narrower than the table's minimum width.
3. Dashboard metric cards SHALL reflow from a 4-column grid to a 2-column grid below 768px and a single column below 480px.

**Backend mapping:** Not applicable.

---

## Backend Gaps & Resolution Strategy

### Category A — Client-side MVP (deliverable now)

| # | Gap | Why no endpoint | Recommended resolution | Affects |
|---|-----|-----------------|------------------------|---------|
| 1 | Token refresh / revocation | No `/auth/refresh` endpoint | Build Axios 401 interceptor with single retry seam; current: clear → login. Add `POST /auth/refresh`. | Req 2, 3, 4 |
| 9 | Admin profile GET/PUT | No `/auth/me` for admin | Display from JWT claims; editing disabled. Add `GET`/`PUT /auth/admin/me`. | Req 15 |

### Category B — Requires new backend endpoint

| # | Gap | Why no endpoint | Recommended resolution | Affects |
|---|-----|-----------------|------------------------|---------|
| 2 | Platform dashboard analytics | No aggregation endpoint | Display placeholder UI with documented expected endpoints: `GET /admin/analytics/summary`, `GET /admin/analytics/orders-per-day`. | Req 5 |
| 3 | Admin restaurant management | `PATCH /restaurants/{id}/status` requires `RESTAURANT_OWNER` role | Implement admin version: `PATCH /admin/restaurants/{id}/status` with `ADMIN` role. | Req 8 |
| 4 | Admin order management | `GET /orders/my-orders` is `CUSTOMER`-role only | Add `GET /admin/orders?page=&size=&status=&from=&to=` and `PATCH /admin/orders/{orderId}/status` with `ADMIN` role. | Req 9, 10 |
| 5 | Delivery partner management | No admin delivery partner list endpoint | Add `GET /admin/delivery-partners?page=&size=&online=&assigned=`, `GET /admin/delivery-partners/{id}`, `PATCH /admin/delivery-partners/{id}/status`. | Req 11 |
| 6 | Customer management | No user list endpoint | Add `GET /admin/customers?page=&size=&search=`, `GET /admin/customers/{id}`, `PATCH /admin/customers/{id}/status`. | Req 12 |
| 7 | Revenue and analytics | No revenue aggregation or analytics endpoint | Add `GET /admin/analytics/revenue?from=&to=&granularity=daily`, `GET /admin/analytics/top-restaurants`, `GET /admin/analytics/delivery-performance`. | Req 13 |
| 8 | System notification history | Notification service is an empty stub | Add `GET /admin/notifications?page=&size=` once notification service is implemented. | Req 14 |
