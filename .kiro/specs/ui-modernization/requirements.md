# Requirements Document

## Introduction

This document captures the requirements for the **UI Modernization** feature, derived from the
approved design (`design.md`). The work is a frontend-only UI/UX overhaul of the two Flutter
apps (`frontend/Customer_app`, `frontend/Delivery_app`) plus one explicitly-scoped backend
**guard** in the delivery service that protects delivery-completion integrity.

The guiding principle is **refinement, not rewrite**: all currently-working behavior (live
tracking, rider location publishing, geocoding-based delivery location, marker bearing
animation, partner identity, the STOMP/Kafka transport) keeps working exactly as today. The
feature layers modern styling and a small set of behavioral corrections on top of the existing
architecture (Riverpod + codegen, freezed, `AppTokens`, `google_maps_flutter`, `geolocator`).

Requirements 1–8 cover the eight in-scope changes. Requirements 9–11 capture cross-cutting
non-functional criteria (accessibility, platform support, and preservation of existing
behavior).

## Glossary

- **System**: The UI Modernization feature as a whole, spanning the Customer app, the Delivery
  app, and the in-scope Delivery service completion guard.
- **Customer_App**: The Flutter customer application (`frontend/Customer_app`).
- **Delivery_App**: The Flutter delivery/rider application (`frontend/Delivery_app`).
- **Order_Service**: The backend order microservice that owns order state transitions.
- **Delivery_Service**: The backend delivery microservice that owns assignment and partner state.
- **MarkerIconFactory**: The per-app component that renders and caches custom map-marker bitmaps.
- **MarkerAnimator**: The existing per-app component that supplies smooth marker interpolation
  and a `bearing` value (unchanged by this feature).
- **Cart_Badge**: The reactive item-count badge on the Customer_App cart icon (`CartIconButton`).
- **DialerService**: The per-app helper (`launchDialer`) that opens the native phone dialer.
- **Checkout_Screen**: The Customer_App checkout screen.
- **OrderDeliveredConsumer**: The new Delivery_Service Kafka consumer for the `order-delivered`
  topic that releases the assigned rider.
- **Rider_Self_Completion_Endpoint**: The delivery endpoint
  `POST /api/delivery/assignments/{orderId}/delivered` that today lets a rider self-complete.
- **BrandPalette**: The canonical color-constant block (`lib/core/theme/brand_palette.dart`)
  replicated identically in both apps.
- **AppTokens**: The existing `ThemeExtension` token set in each app.
- **OfferCard**: The redesigned delivery-home card representing a single pending delivery offer.
- **ActiveAssignmentCard**: The redesigned delivery-home card representing the accepted, active
  assignment.
- **Delivery_Location**: The latitude/longitude used to deliver an order, resolved from device
  GPS or address geocoding.

---

## Requirements

### Requirement 1: Custom rider/scooter map marker (both apps)

**User Story:** As a customer tracking my order and as a rider navigating a delivery, I want the
rider's position shown as a recognizable scooter marker, so that I can quickly identify the
moving delivery vehicle on the map.

#### Acceptance Criteria

1. WHEN the tracking map renders the rider position, THE Customer_App SHALL display the rider
   using a custom circular scooter "puck" marker rendered from a bitmap.
2. WHEN the navigation map renders the rider position, THE Delivery_App SHALL display the rider
   using the same custom circular scooter "puck" marker.
3. WHILE the custom rider marker bitmap has not finished rendering, THE Customer_App and
   Delivery_App SHALL display the existing default marker so the rider position is never blank.
4. WHEN the custom rider marker bitmap finishes rendering, THE Customer_App and Delivery_App
   SHALL replace the default marker with the custom puck marker.
5. THE Customer_App and Delivery_App SHALL apply the existing `MarkerAnimator` bearing as the
   custom rider marker's rotation and SHALL keep the marker anchor at (0.5, 0.5).
6. THE MarkerIconFactory SHALL render the marker bitmap at the device pixel ratio so the marker
   is density-correct.
7. THE MarkerIconFactory SHALL fill the scooter puck using the `riderMarker` color token
   (`Icons.two_wheeler` glyph).
8. WHEN the MarkerIconFactory is asked for a marker it has already produced for the same icon,
   color, size, and device pixel ratio, THE MarkerIconFactory SHALL return the cached bitmap
   rather than re-rendering.
9. IF rendering the custom rider marker bitmap fails or the marker cannot otherwise be displayed,
   THEN THE Customer_App and Delivery_App SHALL continue to display the default marker without
   crashing.

### Requirement 2: Cart item-count badge (customer app)

**User Story:** As a customer browsing restaurants, I want to see how many items are in my cart
on the cart icon, so that I always know my cart state without opening it.

#### Acceptance Criteria

1. WHILE the cart contains between 1 and 99 items, THE Cart_Badge SHALL display the cart's exact
   total item count on the cart icon.
2. WHILE the cart contains zero items, THE Cart_Badge SHALL be hidden.
3. WHEN the cart total item count changes, THE Cart_Badge SHALL update to reflect the new count.
4. IF the cart total item count exceeds 99, THEN THE Cart_Badge SHALL display "99+" in place of
   the raw number.
5. THE Customer_App SHALL show the Cart_Badge on every screen that displays the cart icon,
   including the home screen and the restaurant detail screen.
6. WHEN the cart icon is activated, THE Customer_App SHALL navigate to the cart screen.
7. THE Cart_Badge SHALL expose an accessibility label announcing "Cart, N items", where N is the
   current total item count.

### Requirement 3: Customer-only delivery completion and rider release (both apps + delivery guard)

**User Story:** As a customer, I want to be the only one who can confirm my order was delivered,
so that an order is never marked complete before I actually receive it; and as a rider, I want
to be released for new orders as soon as the customer confirms, so that I am never left stranded.

#### Acceptance Criteria

1. WHEN the owning customer submits an authenticated delivery confirmation
   (`POST /orders/{id}/receive`) for an order in `OUT_FOR_DELIVERY`, THE Order_Service SHALL
   transition that order to `DELIVERED`. *(G1 — positive path)*
2. THE Order_Service SHALL permit the transition of an order to `DELIVERED` solely in response to
   the owning customer's authenticated confirmation of an order in `OUT_FOR_DELIVERY`. *(G1 —
   exclusivity)*
3. WHEN an order becomes `DELIVERED`, THE Delivery_Service SHALL release the assigned partner by
   setting the assignment to `DELIVERED` (with `deliveredAt`) and setting the partner to
   `available`. *(G2 — rider release preserved)*
4. WHEN the Delivery_Service processes an `order-delivered` event for an assignment that is
   already `DELIVERED`, THE Delivery_Service SHALL leave the assignment and partner state
   unchanged. *(G2 — idempotent release)*
5. WHEN a customer confirmation completes an order, THE Delivery_Service SHALL free the assigned
   rider via the `OrderDeliveredConsumer` so that no rider remains permanently unavailable.
   *(G3 — no stranded rider)*
6. WHILE an assignment is in the picked-up state, THE Delivery_App SHALL replace the former
   "Confirm Delivery" control with a non-actionable "Waiting for customer confirmation" state.
7. THE Delivery_App SHALL remove the rider self-completion code path (the confirm-delivery use
   case, the repository `markDelivered` operation, and the `/delivered` call) so that no client
   code can trigger rider self-completion.
8. THE Delivery_Service SHALL remove or guard the Rider_Self_Completion_Endpoint such that it can
   no longer transition an order to `DELIVERED`.
9. IF a request reaches a still-present (guarded) Rider_Self_Completion_Endpoint, THEN THE
   Delivery_Service SHALL reject the request with a client error (4xx) without completing the
   order.
10. WHEN the Delivery_App next polls for the active assignment after the order is `DELIVERED`,
    THE Delivery_App SHALL clear the local active-assignment cache.
11. THE System SHALL keep the existing `order-delivered` topic contract unchanged (the event is
    still emitted on completion; only the rider-release trigger moves to the OrderDeliveredConsumer).

### Requirement 4: Hide geo-coordinates from the customer at checkout

**User Story:** As a customer placing an order, I want to confirm my delivery location without
seeing or editing raw coordinates, so that checkout is simple and I never submit bad coordinates.

#### Acceptance Criteria

1. THE Checkout_Screen SHALL present the Delivery_Location only as a human-readable address and a
   non-numeric status indicator, keeping the resolved latitude and longitude as internal screen
   state that is neither displayed nor editable.
2. WHEN the Checkout_Screen opens, THE Customer_App SHALL attempt to resolve the Delivery_Location
   from device GPS and reverse-geocode it to an address.
3. WHEN the customer enters an address and triggers the address search, THE Customer_App SHALL
   geocode the address into the internal Delivery_Location coordinates.
4. WHILE the Delivery_Location is being resolved, THE Checkout_Screen SHALL show a non-numeric
   "resolving" indicator.
5. WHEN the Delivery_Location resolves successfully, THE Checkout_Screen SHALL show a non-numeric
   confirmation (for example, "Delivering to this location").
6. IF Delivery_Location resolution fails, THEN THE Checkout_Screen SHALL show non-numeric
   guidance and keep the "Place Order" action disabled.
7. WHILE no Delivery_Location has resolved (latitude or longitude unset), THE Checkout_Screen
   SHALL keep the "Place Order" action disabled.
8. WHEN the customer places the order, THE Customer_App SHALL submit the Delivery_Location
   coordinates obtained from GPS or geocoding and no other source (no default or hand-typed
   coordinates).
9. THE Customer_App SHALL preserve the existing `DeliveryLocationDto` order-payload contract.

### Requirement 5: Modernize the visual design (both apps)

**User Story:** As a user of either app, I want a modern, consistent visual design, so that the
product feels polished and trustworthy.

#### Acceptance Criteria

1. THE Customer_App and Delivery_App SHALL derive component styling from `ThemeData` component
   themes (card, filled button, outlined button, input decoration, app bar, chip, snackbar,
   divider) rather than per-screen literal styles.
2. THE Customer_App and Delivery_App SHALL apply the same typography scale (shared `TextTheme`
   ramp) so both apps render a consistent type ramp.
3. THE Delivery_App SHALL define the shared `TextTheme` (which it currently lacks).
4. THE Customer_App and Delivery_App SHALL provide shared `EmptyState`, `LoadingState`, and
   `ErrorState` widgets under `lib/core/widgets/` for async/list screens.
5. THE Customer_App and Delivery_App SHALL replace the hardcoded brand-green header colors in the
   tracking and navigation screens with theme-derived colors.
6. WHEN applying the modernized styling, THE System SHALL preserve the existing screens'
   functionality and navigation.
7. IF a styling change (new `ThemeData`, component theme, or shared widget) would break an
   existing screen's functionality, layout, or interactions, THEN THE System SHALL prioritize
   functionality preservation and retain the legacy styling for that element rather than apply
   the breaking change.

### Requirement 6: Tappable call icon opens the native dialer (both apps)

**User Story:** As a customer and as a rider, I want to tap the call icon to phone the other
party, so that I can coordinate the delivery.

#### Acceptance Criteria

1. WHEN the customer taps the call action on the tracking screen (assignment present and phone
   available), THE Customer_App SHALL open the native phone dialer prefilled with the sanitized
   phone number.
2. WHEN the rider taps the call action on the navigation screen (customer phone available), THE
   Delivery_App SHALL open the native phone dialer prefilled with the sanitized customer phone
   number.
3. THE DialerService SHALL sanitize the phone number by removing every character that is not a
   digit or `+`.
4. IF the sanitized phone number is empty, THEN THE DialerService SHALL return a failure result
   without launching the dialer.
5. IF launching the dialer fails, THEN THE Customer_App and Delivery_App SHALL show a
   non-blocking error message and continue running.
6. WHILE no phone number is available for the current assignment, THE Delivery_App SHALL keep the
   call action disabled.
7. THE Customer_App SHALL add the `url_launcher` dependency required to launch the dialer.

### Requirement 7: Redesigned delivery offer and active-assignment experience (delivery app)

**User Story:** As a rider, I want a polished offer and active-assignment experience, so that I
can quickly understand and act on incoming orders.

#### Acceptance Criteria

1. WHILE the rider is offline, THE Delivery_App SHALL show an empty state prompting the rider to
   go online.
2. WHILE the rider is online with no pending offers, THE Delivery_App SHALL show a waiting empty
   state.
3. WHEN one or more offers are available, THE Delivery_App SHALL render each offer as an OfferCard
   showing the restaurant name with pickup address, the customer area with drop address, and the
   item count.
4. WHEN a new offer first appears from polling, THE Delivery_App SHALL animate it in with an
   entrance (slide and/or fade) transition.
5. WHEN the rider accepts an offer, THE Delivery_App SHALL invoke the existing `acceptOffer` flow
   unchanged and, on success, present the ActiveAssignmentCard.
6. WHILE an offer accept is in progress, THE Delivery_App SHALL show inline progress on that
   OfferCard.
7. IF accepting an offer fails, THEN THE Delivery_App SHALL return the OfferCard to an actionable
   state and show an error message.
8. WHEN the rider dismisses or swipes an OfferCard, THE Delivery_App SHALL hide that offer from
   the current view for the remainder of the session (session-local dismiss; there is no backend
   decline).
9. THE Delivery_App SHALL filter polled offers against the session-local dismissed set.
10. WHERE there is no backend decline mechanism, THE Delivery_App SHALL store the dismissal only
    in volatile session state, so that a dismissed offer can reappear once the session-local
    dismissed set is reset.
11. WHILE there is an active assignment, THE Delivery_App SHALL show a single ActiveAssignmentCard
    with a status timeline (Assigned → Picked up → Delivered) and the next navigation action.

### Requirement 8: Consistent, documented color system (both apps)

**User Story:** As a user, I want both apps to look like one product family with consistent brand
colors, so that the experience feels cohesive.

#### Acceptance Criteria

1. THE Customer_App and Delivery_App SHALL each define a canonical BrandPalette
   (`lib/core/theme/brand_palette.dart`) with identical color values.
2. THE Customer_App and Delivery_App SHALL seed `ColorScheme.fromSeed` with
   `BrandPalette.brandPrimary` (`#2B9E49`).
3. THE Customer_App and Delivery_App SHALL extend AppTokens with `riderMarker`, `customerMarker`,
   and `restaurantMarker` color tokens.
4. THE custom rider marker SHALL derive its fill color from the `riderMarker` token.
5. THE Customer_App and Delivery_App SHALL replace hardcoded brand-green and `Colors.*Accent`
   literals in screens with `ColorScheme`/AppTokens references.
6. THE Customer_App and Delivery_App SHALL each include a drift-guard test asserting that the
   `ColorScheme` seed and key token values equal the documented BrandPalette constants.

### Requirement 9: Accessibility (non-functional)

**User Story:** As a user who relies on assistive technology or larger touch targets, I want the
new UI to be accessible, so that I can use the apps comfortably.

#### Acceptance Criteria

1. THE interactive controls introduced or modified by this feature (cart, call, accept, dismiss,
   navigation actions, and Place Order) SHALL each have a minimum tap target of 48×48 logical
   pixels.
2. THE new and modified icon controls (cart, call, offer accept/dismiss, marker info) SHALL each
   expose an accessibility label.
3. WHERE brand colors are applied to body text and UI components, THE System SHALL meet WCAG AA
   contrast for those elements. *(Note: full WCAG conformance requires manual assistive-technology
   testing and expert review.)*
4. WHEN the OS text scale is increased up to 200%, THE redesigned text rows SHALL remain readable
   without clipping.

### Requirement 10: Platform support for the dialer (non-functional)

**User Story:** As a user on either Android or iOS, I want the call action to work on my device,
so that the dialer launches regardless of platform.

#### Acceptance Criteria

1. THE dialer feature SHALL function on both Android and iOS.
2. THE Customer_App and Delivery_App SHALL each launch the dialer independently, without
   delegating dialing to the other app.
3. WHERE the platform is Android, THE Customer_App and Delivery_App SHALL launch the dialer via
   the `tel:` implicit intent and SHALL declare a `tel`/`DIAL` `<queries>` entry in
   `AndroidManifest.xml`.
4. WHERE the platform is iOS, THE Customer_App and Delivery_App SHALL declare `tel` in
   `LSApplicationQueriesSchemes` within `ios/Runner/Info.plist`.

### Requirement 11: Preserve existing behavior (non-functional)

**User Story:** As a stakeholder, I want all currently-working behavior preserved, so that the
modernization is a refinement and not a regression.

#### Acceptance Criteria

1. THE System SHALL preserve live order tracking in the Customer_App.
2. THE System SHALL preserve rider location publishing in the Delivery_App.
3. THE System SHALL preserve geocoding-based Delivery_Location resolution.
4. THE System SHALL preserve marker bearing/rotation animation via `MarkerAnimator`.
5. THE System SHALL preserve the existing STOMP socket, Kafka topology, and geocoding/directions
   services without modification.
6. THE System SHALL preserve the existing order/delivery completion API and event contract,
   limiting backend change to the rider-release trigger described in Requirement 3.

---

## Admin Web App — scope extension (Requirements 12–18)

> These requirements **extend** this document to cover the browser-based admin app
> (`frontend/admin-web`). They map to design **Admin items A1–A6** and continue the numbering
> after Requirement 11. Requirements 1–11 (the Flutter apps + delivery guard) are unchanged.
> Where useful, admin requirements **reuse** the intent of Requirement 9 (accessibility) and
> Requirement 11 (preserve existing behavior) rather than duplicating them.
>
> **Supersedes `.kiro/specs/admin-web/`:** that separate spec is stale (it lists admin
> orders/delivery/analytics as backend gaps that are, in fact, implemented and ADMIN-guarded).
> This section is the current source of truth for admin-web work; the old spec is retained but
> informational only.

### Glossary (admin addendum)

- **Admin_Web**: The React admin web application (`frontend/admin-web`).
- **Admin_Dashboard**: The Admin_Web dashboard/analytics surface (`Dashboard.tsx`, `Analytics.tsx`).
- **Admin_Live_Map**: The new Admin_Web live rider map page (`LiveMap.tsx`) and its STOMP client.
- **Restaurant_Service**: The backend restaurant microservice (`/restaurants*`).
- **Tracking_Service**: The backend tracking microservice that broadcasts rider locations over
  STOMP (`/ws/tracking`, topic `/topic/admin/riders/location`).
- **Api_Gateway**: The Spring Cloud Gateway that enforces JWT and injects `X-User-*` headers,
  including for `/ws/tracking/**`.
- **Brand_Green**: The shared brand color `#2B9E49` (the same value used by the Flutter
  `BrandPalette`).
- **Order_Aggregates**: The client-side, deterministic aggregation of `GET /orders/admin` used to
  render Admin_Dashboard charts.

---

### Requirement 12: Admin brand alignment and visual modernization (A1)

**User Story:** As an operator using the admin portal, I want it to share the product's brand
identity and a polished, consistent look, so that the three apps feel like one product family.

#### Acceptance Criteria

1. THE Admin_Web SHALL set the shadcn `--primary` and `--primary-foreground` design tokens (light
   and dark) so the primary color equals Brand_Green.
2. THE Admin_Web SHALL set the `--sidebar-primary` token in both light and dark themes to
   Brand_Green, replacing the current dark purple value.
3. THE Admin_Web SHALL define a brand-anchored chart color palette (`--chart-1` … `--chart-5`) and
   a brand-tinted focus `--ring` in place of the current grayscale values.
4. THE Admin_Web SHALL drive brand color through the CSS design tokens consumed by
   `tailwind.config.ts`, so screens reference token-mapped color utilities rather than hardcoded
   color literals.
5. THE Admin_Web SHALL provide shared `EmptyState`, `LoadingState`, and `ErrorState` components and
   apply them to the asynchronous data pages.
6. THE Admin_Web SHALL include a drift-guard test asserting that the recolored brand tokens equal
   the documented Brand_Green values.
7. WHEN the operator toggles between light and dark themes, THE Admin_Web SHALL preserve the
   existing theme-switching behavior while applying the brand tokens.

### Requirement 13: Admin restaurant management (A2)

**User Story:** As an administrator, I want to browse restaurants and change their active status,
so that I can manage catalog availability across the platform.

#### Acceptance Criteria

1. WHEN the operator opens the restaurants page, THE Admin_Web SHALL list restaurants from
   `GET /restaurants`, reading the paginated `ApiResponse` content payload.
2. WHEN the operator opens a restaurant's detail view, THE Admin_Web SHALL load that restaurant
   from `GET /restaurants/{id}`.
3. WHEN an ADMIN operator toggles a restaurant's status, THE Admin_Web SHALL call
   `PATCH /restaurants/{id}/status` with the new `active` value. *(This endpoint already authorizes
   ADMIN: the controller permits `RESTAURANT_OWNER` and `ADMIN`, and the service ownership check
   returns early for ADMIN — no backend change is required.)*
4. WHEN a restaurant status update succeeds, THE Admin_Web SHALL refresh the restaurant data so the
   displayed status reflects the new value.
5. IF a restaurant status update fails, THEN THE Admin_Web SHALL show an error message and retain
   the previously displayed status.

### Requirement 14: Admin delivery partner monitoring (A3)

**User Story:** As an administrator, I want to monitor and manage delivery partners, so that I can
oversee the fleet and its availability.

#### Acceptance Criteria

1. WHEN the operator opens the delivery partners page, THE Admin_Web SHALL list partners from
   `GET /api/delivery/partners/admin` with their real online, availability, and current-assignment
   data.
2. WHEN the operator forces a partner online or offline, THE Admin_Web SHALL call
   `POST /api/delivery/partners/{id}/online` or `POST /api/delivery/partners/{id}/offline`
   respectively and then refresh the list.
3. WHERE the operator selects an online, available, or assigned filter, THE Admin_Web SHALL display
   only partners matching the selected filter (assigned meaning a non-null current assignment).
4. WHEN the operator requests a refresh, THE Admin_Web SHALL reload the partner list.
5. THE Admin_Web SHALL preserve the existing working behavior of the delivery partners page
   (real-data fetch and online/offline toggle).

### Requirement 15: Admin live rider map (A4) — net-new

**User Story:** As an administrator, I want a live map of active riders, so that I can monitor
deliveries in real time.

#### Acceptance Criteria

1. THE Admin_Web SHALL provide a live rider map page with a corresponding route and a sidebar
   navigation entry.
2. WHEN the live map page opens, THE Admin_Live_Map SHALL open a STOMP-over-WebSocket connection to
   `/ws/tracking` using a WebSocket URL derived from `VITE_API_URL` (using `wss:` for an `https:`
   base and `ws:` otherwise).
3. WHEN connected, THE Admin_Live_Map SHALL subscribe to `/topic/admin/riders/location` and parse
   each `RiderLocationUpdate` payload (`riderId`, `orderId`, `latitude`, `longitude`, `timestamp`).
4. WHEN a rider location update is received, THE Admin_Live_Map SHALL upsert a single map marker per
   `riderId` (most recent timestamp wins) and move that marker to the updated position.
5. THE Admin_Live_Map SHALL display the current rider count and a last-seen indicator.
6. WHEN the connection drops, THE Admin_Live_Map SHALL attempt to reconnect and reflect the
   connection state.
7. THE Admin_Live_Map SHALL render map tiles that require no map-provider API key (OpenStreetMap
   tiles).
8. WHERE the Api_Gateway reads the JWT only from the `Authorization` header (which a browser cannot
   set on a WebSocket handshake), THE Api_Gateway SHALL be extended to accept the JWT for the
   `/ws/tracking/**` route via a query parameter and inject the same `X-User-*` headers, so the
   Admin_Live_Map handshake is authorized. *(Explicitly-scoped, approval-gated backend change.)*
9. IF the live map connection cannot be authenticated or is lost, THEN THE Admin_Live_Map SHALL show
   a non-blocking connection-error state and continue attempting to reconnect without affecting the
   rest of the Admin_Web.

### Requirement 16: Admin active order monitoring (A5)

**User Story:** As an administrator, I want to monitor active orders and act on them, so that I can
keep in-flight orders moving.

#### Acceptance Criteria

1. WHEN the operator opens the orders page, THE Admin_Web SHALL list orders from `GET /orders/admin`.
2. WHILE the orders page is open, THE Admin_Web SHALL auto-refresh the order list on an interval so
   in-flight orders stay current.
3. WHERE the operator selects one or more status filters, THE Admin_Web SHALL display only orders
   whose status is in the selected set, and SHALL display all orders when no status is selected.
4. WHEN the operator enters a search term, THE Admin_Web SHALL display only orders whose id,
   customer name, or restaurant id contains the term (case-insensitive).
5. WHERE an order's status is `PENDING_PAYMENT` or `CONFIRMED`, THE Admin_Web SHALL offer an accept
   action that calls `POST /orders/{id}/accept`.
6. WHERE an order's status is `PREPARING`, THE Admin_Web SHALL offer a ready action that calls
   `POST /orders/{id}/ready`.
7. WHEN an accept or ready action succeeds, THE Admin_Web SHALL refresh the order list.

### Requirement 17: Admin analytics dashboard (A6)

**User Story:** As an administrator, I want the dashboard to show real metrics and charts, so that I
can understand platform performance instead of placeholder data.

#### Acceptance Criteria

1. WHEN the Admin_Dashboard loads, THE Admin_Web SHALL display the four metrics from
   `GET /analytics/admin` (`totalOrders`, `totalRevenue`, `pendingOrders`, `deliveredOrders`) in
   place of the current hardcoded values.
2. THE Admin_Web SHALL remove the "Phase 3" `PendingFeature` placeholder from the Admin_Dashboard
   where real data is now displayed.
3. THE Admin_Web SHALL render analytics charts (order-status distribution, orders-per-day, and
   revenue-per-day) computed by client-side aggregation of `GET /orders/admin` using recharts.
4. THE Order_Aggregates computation SHALL be deterministic: equal order inputs SHALL produce equal
   aggregate outputs, status counts SHALL sum to the order count, and per-day revenue SHALL equal
   the sum of order totals in each day bucket.
5. IF an analytics or orders request fails, THEN THE Admin_Web SHALL display an error state and
   SHALL NOT display fabricated placeholder metrics.
6. THE Admin_Web SHALL derive charts only from existing endpoints and SHALL NOT depend on
   analytics endpoints that do not exist (richer server-side analytics are recorded as an optional
   future backend gap).

### Requirement 18: Admin accessibility and preserved behavior (non-functional)

**User Story:** As an operator who relies on assistive technology, and as a stakeholder who does not
want regressions, I want the admin app to stay accessible and keep its working behavior.

#### Acceptance Criteria

1. THE interactive controls added or modified in the Admin_Web (theme, filters, toggles, order
   actions, and map controls) SHALL each expose an accessible name.
2. THE Admin_Web data tables SHALL use semantic table markup with associated column headers.
3. THE Admin_Web navigation and controls SHALL be keyboard operable with a visible focus indicator.
4. THE Admin_Web SHALL pass automated accessibility checks (`@axe-core/react`) on the key pages with
   no serious violations. *(Full WCAG conformance requires manual assistive-technology testing and
   expert review.)*
5. WHERE Brand_Green is applied to text or UI components, THE Admin_Web SHALL meet WCAG AA contrast
   for those elements.
6. THE Admin_Web SHALL preserve the existing authentication and session behavior: the axios client
   SHALL continue to attach the `Authorization: Bearer` token and, on a 401 response, SHALL log out
   and redirect to `/login`.
7. THE Admin_Web SHALL preserve the existing working delivery partners page behavior when the shared
   modernization changes are applied.
