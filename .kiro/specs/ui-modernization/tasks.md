# Implementation Plan: UI Modernization (Customer & Delivery apps)

## Overview

This plan implements the approved design as a series of incremental, test-driven coding steps in
**Dart/Flutter** for both apps (`frontend/Customer_app`, `frontend/Delivery_app`) plus a small
**Java/Spring** addition in the delivery service (`backend/delivery`) for the Item 3 completion
guard. Because the two apps are separate Flutter packages with no shared package, components that
span both apps (BrandPalette, AppTokens marker fields, MarkerIconFactory, dialer helper) are
implemented once per app via separate sub-tasks.

Sequencing de-risks the work per the design: foundation first (color system + theme/token
scaffolding + shared widgets + test harness), then small isolated changes (cart badge, dialer),
then the marker factory, then checkout, then the offer/assignment redesign, and the cross-service
completion guard (Item 3) **last**. Test sub-tasks are marked optional with `*`; property tests
each reference a Correctness Property from the design and are tagged
`Feature: ui-modernization, Property {n}` and run a minimum of 100 generated iterations.

## Tasks

- [ ] 1. Design-system foundation and test scaffolding (Item 8 + Item 5 core)
  - [ ] 1.1 Set up shared test scaffolding and a property-based testing harness in both apps
    - Reuse the existing `Customer_app/test/` and `Delivery_app/test/` folders; add a
      `test/support/` directory in each app with input generators, common `mocktail` fakes, and a
      small property-based testing harness (e.g., the `glados` package or a custom generator loop)
      defaulting to 100 iterations
    - Add a helper that emits the tag string `Feature: ui-modernization, Property {n}: {title}` so
      every property test is consistently tagged
    - _Supports: Correctness Properties 1-6 and the Req 8.6 drift-guard tests_
  - [ ] 1.2 Customer_app design-system foundation
    - NEW `Customer_app/lib/core/theme/brand_palette.dart` (canonical constants from the design table)
    - EDIT `Customer_app/lib/core/theme/app_tokens.dart`: add `riderMarker`/`customerMarker`/`restaurantMarker` and update `copyWith`/`lerp`
    - EDIT `Customer_app/lib/core/theme/app_theme.dart`: seed `ColorScheme.fromSeed` with `BrandPalette.brandPrimary`; add `cardTheme`, `filledButtonTheme`, `outlinedButtonTheme`, `inputDecorationTheme`, `appBarTheme`, `chipTheme`, `snackBarTheme`, `dividerTheme` built from tokens
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 5.1, 5.5, 5.6, 5.7_
  - [ ] 1.3 Delivery_app design-system foundation (incl. shared TextTheme it currently lacks)
    - NEW `Delivery_app/lib/core/theme/brand_palette.dart` (identical values to the customer app)
    - EDIT `Delivery_app/lib/core/theme/app_tokens.dart`: add the three marker tokens; align `success`/`warning`/`error`/`info` and `deliveryStatusColors`
    - EDIT `Delivery_app/lib/core/theme/app_theme.dart`: seed with `BrandPalette.brandPrimary`; add the shared `TextTheme` ramp matching the customer app; add the same component themes as 1.2
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 5.1, 5.2, 5.3, 5.5, 5.6, 5.7_
  - [ ] 1.4 Customer_app shared async/state widgets
    - NEW `Customer_app/lib/core/widgets/empty_state.dart`, `loading_state.dart`, `error_state.dart`
    - _Requirements: 5.4_
  - [ ] 1.5 Delivery_app shared async/state widgets
    - NEW `Delivery_app/lib/core/widgets/empty_state.dart`, `loading_state.dart`, `error_state.dart`
    - _Requirements: 5.4_
  - [ ]* 1.6 Customer_app theme drift-guard test
    - Assert the `ColorScheme` seed and key token values (brand + marker tokens) equal the documented `BrandPalette` constants
    - _Requirements: 8.6_
  - [ ]* 1.7 Delivery_app theme drift-guard test
    - Assert the `ColorScheme` seed and key token values equal the documented `BrandPalette` constants
    - _Requirements: 8.6_

- [ ] 2. Cart item-count badge (Item 2, customer app)
  - [ ] 2.1 Implement `CartIconButton` with an extracted pure badge-mapping function
    - NEW `Customer_app/lib/features/cart/presentation/widgets/cart_icon_button.dart` (Riverpod `ConsumerWidget`, `select((c) => c.totalItems)`)
    - Extract a pure helper (visible iff count > 0; label = count for 1-99, `"99+"` above 99) so the mapping is unit/property-testable
    - Add `Semantics` label "Cart, N items" and ensure a >=48x48 tap target; preserve existing navigation + tooltip
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.6, 2.7, 9.1, 9.2_
  - [ ] 2.2 Wire `CartIconButton` into the AppBars
    - EDIT `Customer_app/lib/features/home/presentation/screens/home_screen.dart` and `Customer_app/lib/features/restaurant/presentation/restaurant_detail_screen.dart` to replace the inline cart `IconButton`
    - _Requirements: 2.5, 2.6_
  - [ ]* 2.3 Property test: cart badge visibility and label mapping
    - **Property 1: Cart badge visibility and label mapping** (tag `Feature: ui-modernization, Property 1`)
    - **Validates: Requirements 2.1, 2.2, 2.4**
  - [ ]* 2.4 Widget test: badge reactivity, placement, and semantics
    - Hidden at 0; updates when the cart changes; announces "Cart, N items"
    - _Requirements: 2.3, 2.5, 2.7_

- [ ] 3. Tappable call icon -> native dialer (Item 6 + Item 10 platform config, both apps)
  - [ ] 3.1 Customer_app dialer helper + dependency + tracking wiring
    - EDIT `Customer_app/pubspec.yaml` to add `url_launcher: ^6.3.2`
    - NEW `Customer_app/lib/core/utils/dialer.dart` (`launchDialer`: sanitize to `[0-9+]`, fail on empty, `launchUrl` `tel:` directly)
    - EDIT `Customer_app/lib/features/tracking/presentation/tracking_screen.dart`: set the phone `IconButton.onPressed`; floating SnackBar on failure; tooltip/Semantics "Call"; >=48px target
    - _Requirements: 6.1, 6.3, 6.4, 6.5, 6.7, 9.1, 9.2_
  - [ ] 3.2 Customer_app platform configuration for `tel:`
    - EDIT `Customer_app/ios/Runner/Info.plist`: add `tel` to `LSApplicationQueriesSchemes`
    - EDIT `Customer_app/android/app/src/main/AndroidManifest.xml`: add a `tel`/`DIAL` `<queries>` entry
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  - [ ] 3.3 Delivery_app dialer helper + navigation wiring
    - NEW `Delivery_app/lib/core/utils/dialer.dart` (same `launchDialer` contract)
    - EDIT `Delivery_app/lib/features/navigation/presentation/screens/navigation_screen.dart`: enable the call icon only when `assignment.customerPhone != null`, then call `launchDialer`; SnackBar on failure; tooltip/Semantics
    - _Requirements: 6.2, 6.3, 6.4, 6.5, 6.6, 9.1, 9.2_
  - [ ] 3.4 Delivery_app platform configuration for `tel:`
    - EDIT `Delivery_app/ios/Runner/Info.plist` and `Delivery_app/android/app/src/main/AndroidManifest.xml` as in 3.2
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  - [ ]* 3.5 Customer_app property test: dialer sanitization and launch gating
    - **Property 2: Dialer sanitization and launch gating** (tag `Feature: ui-modernization, Property 2`)
    - **Validates: Requirements 6.3, 6.4**
  - [ ]* 3.6 Delivery_app property test: dialer sanitization and launch gating
    - **Property 2: Dialer sanitization and launch gating** (tag `Feature: ui-modernization, Property 2`)
    - **Validates: Requirements 6.3, 6.4**
  - [ ]* 3.7 Widget/unit tests: call tap wiring, disabled state, failure message (both apps)
    - Mock the launcher boundary; assert disabled when no phone; SnackBar shown on failure
    - _Requirements: 6.1, 6.2, 6.5, 6.6_

- [ ] 4. Checkpoint - ensure foundation, cart badge, and dialer pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 5. Custom rider/scooter map marker (Item 1, both apps)
  - [ ] 5.1 Customer_app `MarkerIconFactory`
    - NEW `Customer_app/lib/core/maps/marker_icon_factory.dart`: render a circular vehicle "puck" (`Icons.two_wheeler`) via `PictureRecorder`/`Canvas` -> `BitmapDescriptor.bytes`; cache by `(icon, color, sizeDp, devicePixelRatio)` with `clearCache()`
    - _Requirements: 1.6, 1.7, 1.8_
  - [ ] 5.2 Customer_app wire the factory into the tracking rider marker
    - EDIT `Customer_app/lib/features/tracking/presentation/tracking_screen.dart`: build the puck on first frame using `devicePixelRatio` + `tokens.riderMarker`; fall back to the default marker until ready; keep `rotation: bearing` and `anchor (0.5,0.5)`
    - _Requirements: 1.1, 1.3, 1.4, 1.5, 1.9, 11.1, 11.4_
  - [ ] 5.3 Delivery_app `MarkerIconFactory`
    - NEW `Delivery_app/lib/core/maps/marker_icon_factory.dart` (identical contract to 5.1)
    - _Requirements: 1.6, 1.7, 1.8_
  - [ ] 5.4 Delivery_app wire the factory into the navigation rider marker
    - EDIT `Delivery_app/lib/features/navigation/presentation/screens/navigation_screen.dart` (fallback, bearing, anchor as in 5.2)
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 1.9, 11.2, 11.4_
  - [ ]* 5.5 Customer_app property test: marker bitmap cache determinism
    - **Property 6: Marker bitmap cache determinism** (tag `Feature: ui-modernization, Property 6`)
    - **Validates: Requirements 1.8**
  - [ ]* 5.6 Delivery_app property test: marker bitmap cache determinism
    - **Property 6: Marker bitmap cache determinism** (tag `Feature: ui-modernization, Property 6`)
    - **Validates: Requirements 1.8**
  - [ ]* 5.7 Widget/example tests: marker fallback and bearing/anchor/color (both apps)
    - Default marker shown before the puck is ready; rotation/anchor preserved; fill from `riderMarker`
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 1.9_

- [ ] 6. Hide geo-coordinates from the customer at checkout (Item 4, customer app)
  - [ ] 6.1 Replace coordinate fields with internal state + non-numeric status indicator
    - EDIT `Customer_app/lib/features/checkout/presentation/checkout_screen.dart`: remove the lat/lng `TextField`s and the manual-edit tip; introduce private `double? _lat, _lng`; keep the post-frame GPS resolve and address geocoding; show resolving/resolved/failed indicator (no numbers)
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 11.3_
  - [ ] 6.2 Gate Place Order and fix coordinate provenance
    - Enable "Place Order" only when a non-empty address AND resolved `_lat/_lng` exist; pass `_lat!/_lng!` (no parsing, no default); preserve the `DeliveryLocationDto` payload contract; ensure >=48px action
    - Extract the enable/gate decision into a pure function so it is property-testable
    - _Requirements: 4.7, 4.8, 4.9, 9.1_
  - [ ]* 6.3 Property test: Place-Order gate and coordinate provenance
    - **Property 5: Checkout Place-Order gate and coordinate provenance** (tag `Feature: ui-modernization, Property 5`)
    - **Validates: Requirements 4.7, 4.8**
  - [ ]* 6.4 Widget test: resolving/resolved/failed states and disabled-until-resolved
    - Assert no default/hand-typed coordinates are ever submitted
    - _Requirements: 4.1, 4.4, 4.5, 4.6_

- [ ] 7. Checkpoint - ensure marker and checkout changes pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Redesigned delivery offer and active-assignment experience (Item 7, delivery app)
  - [ ] 8.1 Session-local dismissed-offers provider and filter
    - NEW `dismissedOfferIdsProvider` (`StateProvider.autoDispose<Set<String>>`) in the delivery home layer; filter `pendingOffersProvider` output against it
    - Extract the filter (`offers.where((o) => !dismissed.contains(o.orderId))`) as a pure function for property testing
    - _Requirements: 7.8, 7.9, 7.10_
  - [ ] 8.2 `OfferCard` widget
    - NEW `Delivery_app/lib/features/assignment/presentation/widgets/offer_card.dart`: restaurant + pickup, customer area + drop, item-count chip, Accept (primary) / Dismiss (secondary), inline progress while accepting; >=48px targets and labeled actions
    - _Requirements: 7.3, 7.5, 7.6, 7.7, 9.1, 9.2_
  - [ ] 8.3 `ActiveAssignmentCard` widget
    - NEW `Delivery_app/lib/features/assignment/presentation/widgets/active_assignment_card.dart`: status timeline (Assigned -> Picked up -> Delivered) and next navigation action linking to the existing detail screen
    - _Requirements: 7.11_
  - [ ] 8.4 Recompose the delivery home into three animated states
    - EDIT `Delivery_app/lib/features/home/presentation/screens/home_screen.dart`: offline/waiting `EmptyState`s; offer list via `AnimatedSwitcher` + `SlideTransition`/`FadeTransition` keyed by `orderId`; `Dismissible` swipe to session-dismiss; active card on accept (unchanged `acceptOffer`)
    - _Requirements: 7.1, 7.2, 7.4, 7.5, 7.8_
  - [ ]* 8.5 Property test: session-local offer dismissal filter
    - **Property 4: Session-local offer dismissal filter** (tag `Feature: ui-modernization, Property 4`)
    - **Validates: Requirements 7.8, 7.9**
  - [ ]* 8.6 Widget tests: card rendering, entrance animation, accept wiring, session dismiss
    - _Requirements: 7.3, 7.4, 7.5, 7.6, 7.7, 7.11_

- [ ] 9. Customer-only delivery completion and rider release (Item 3 - LAST)
  - [ ] 9.1 Delivery_app: remove the rider self-completion code path and add a waiting state
    - EDIT `Delivery_app/lib/features/assignment/presentation/screens/assignment_detail_screen.dart`: remove the "Confirm Delivery" button from the `pickedUp` state; show a non-actionable "Waiting for customer confirmation" state; keep "Navigate to Customer"
    - EDIT `Delivery_app/lib/features/assignment/presentation/providers/assignment_providers.dart` (remove `confirmDelivery` + its provider), `domain/usecases/confirm_usecases.dart` (remove `ConfirmDeliveryUseCase`), `domain/repositories/assignment_repository.dart` + `data/.../assignment_repository_impl.dart` (remove `markDelivered`); garbage-collect the offline-queue `delivered` plumbing; keep the local active-assignment auto-clear on `DELIVERED`
    - _Requirements: 3.6, 3.7, 3.10_
  - [ ]* 9.2 Delivery_app static/widget test: no self-completion remains
    - Assert no symbol references `markDelivered` / `confirmDelivery` / `/delivered`; `pickedUp` renders no self-complete button
    - _Requirements: 3.6, 3.7_
  - [ ] 9.3 Delivery service: add the `OrderDeliveredEvent` deserializer factory
    - EDIT `backend/delivery/.../config/KafkaConsumerConfig.java`: add a `ConsumerFactory` + `ConcurrentKafkaListenerContainerFactory` for `OrderDeliveredEvent` (reuse the existing `event/OrderDeliveredEvent.java`); keep the `order-delivered` topic contract unchanged
    - _Requirements: 3.3, 3.11, 11.6_
  - [ ] 9.4 Delivery service: add `OrderDeliveredConsumer` to release the rider idempotently
    - NEW `backend/delivery/.../consumer/OrderDeliveredConsumer.java`: on `order-delivered`, set the assignment to `DELIVERED` (+ `deliveredAt`) and call `deliveryPartnerService.markAvailable(partnerId)`; no-op when the assignment is already `DELIVERED`
    - _Requirements: 3.3, 3.4, 3.5_
  - [ ] 9.5 Delivery service: remove/guard the rider self-completion endpoint
    - EDIT `backend/delivery/.../controller/DeliveryAssignmentController.java` and `.../service/DeliveryAssignmentService.java`: remove (or guard to a 4xx) `POST /api/delivery/assignments/{orderId}/delivered` and `completeDelivery` so it can no longer transition an order to `DELIVERED`; ensure the `OrderDeliveredEvent` emission still occurs on completion (now via the customer-driven path/consumer)
    - _Requirements: 3.8, 3.9, 3.11, 11.6_
  - [ ]* 9.6 Delivery service property test: idempotent rider release
    - **Property 3: Idempotent rider release on completion** (tag `Feature: ui-modernization, Property 3`); use mocked repositories; replay the event -> exactly one release
    - **Validates: Requirements 3.3, 3.4**
  - [ ]* 9.7 Delivery service behavioral tests: G1-G3
    - Consumer-driven release frees the rider (assignment `DELIVERED`, partner `available`) end-to-end (G2/G3); the removed/guarded `/delivered` endpoint cannot complete an order and rejects with a 4xx, so completion is customer-only (G1)
    - _Requirements: 3.1, 3.2, 3.5, 3.8, 3.9_

- [ ] 10. Cross-cutting accessibility checks and final verification
  - [ ]* 10.1 Customer_app accessibility tests
    - Assert >=48x48 tap targets and accessibility labels on cart/call/Place-Order controls; verify redesigned text rows do not clip at 200% text scale; assert documented brand-on-surface token pairs meet WCAG AA contrast ratio
    - _Requirements: 9.1, 9.2, 9.3, 9.4_
  - [ ]* 10.2 Delivery_app accessibility tests
    - Assert >=48x48 tap targets and labels on call/accept/dismiss/navigation actions; 200% text-scale readability; AA contrast for documented token pairs
    - _Requirements: 9.1, 9.2, 9.3, 9.4_
  - [ ] 10.3 Final verification - analyze, build, compile, and test; fix issues before completion
    - Run `flutter analyze` and a release/debug build for both `Customer_app` and `Delivery_app`; run `./mvnw -o compile` plus the new delivery-service tests in `backend/delivery`; fix any failures
    - Confirm preserved behavior is intact (live tracking, rider location publishing, geocoding, marker bearing, STOMP/Kafka, completion API/event contract)
    - Note: full WCAG conformance (Req 9.3) and real-device dialer launch (Req 10.1) require manual assistive-technology and on-device verification beyond automated checks
    - _Requirements: 5.6, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_

## Notes

- Sub-tasks marked with `*` are optional tests and can be skipped for a faster path; core
  implementation sub-tasks are never optional.
- Each property test references its design Correctness Property, is tagged
  `Feature: ui-modernization, Property {n}`, and runs a minimum of 100 generated iterations.
- Components spanning both apps are implemented once per app (separate sub-tasks) because the apps
  are independent Flutter packages.
- Item 3 is sequenced last because it is the only cross-service change; its backend guard moves the
  rider-release trigger onto the customer-confirmation event while leaving the `order-delivered`
  topic contract unchanged.
- Requirement 9.3 (WCAG AA) and Requirement 10.1 (real-device dialer) are partially manual:
  automated checks cover token-pair contrast and platform configuration; full conformance needs
  manual review.

---

## Admin Web App — scope extension (Admin items A1–A6)

This group **adds** the browser admin app (`frontend/admin-web`, React 19 + Vite + TypeScript) to
the plan. It continues after task 10 as a new top-level group **11**. Implementation language is
**TypeScript/React** (the app's existing stack). Test sub-tasks are marked optional with `*`;
property tests reference an admin Correctness Property (7–10) and are tagged
`Feature: ui-modernization, Property {n}` with a minimum of 100 iterations (via `fast-check`).

Two verified corrections shape this group: **(1)** `PATCH /restaurants/{id}/status` already
authorizes ADMIN (controller `@PreAuthorize` + `assertOwner` early-return), so A2 needs **no**
backend change; **(2)** the only approval-gated backend change is the gateway WebSocket auth for the
live map (browsers cannot set the `Authorization` header on a WS handshake, and the gateway
`JwtFilter` is header-only).

- [ ] 11. Admin web app (brand alignment, finish real-data pages, live rider map)
  - [ ] 11.1 Add admin dependencies
    - EDIT `frontend/admin-web/package.json`: add `react-leaflet`, `leaflet`, `@stomp/stompjs` (deps) and `@types/leaflet`, `fast-check` (devDeps); install
    - _Requirements: 15.2, 15.3, 15.4, 15.7_
  - [ ] 11.2 Recolor shadcn brand tokens to Brand_Green
    - EDIT `frontend/admin-web/src/index.css`: set `--primary`/`--primary-foreground` (light+dark), `--sidebar-primary` (light+dark, replacing the purple), `--ring`, and `--chart-1..5` to brand-anchored oklch (convert `#2B9E49` / dark `#1F7A38`); leave `--success` as-is
    - EDIT `frontend/admin-web/tailwind.config.ts`: verify the var→color mapping still resolves; add `success`/`warning`/`chart` name mappings only if a component references them by name
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.7_
  - [ ]* 11.3 Theme drift-guard test
    - Assert the recolored brand tokens equal the documented Brand_Green (light + dark) and that `--sidebar-primary` is no longer the old purple
    - _Requirements: 12.6_
  - [ ] 11.4 Shared async-state components and adoption
    - NEW `frontend/admin-web/src/components/shared/{EmptyState,LoadingState,ErrorState}.tsx`; adopt on the data pages, replacing ad-hoc `<div>Loading...</div>` / `<div>Error...</div>`
    - _Requirements: 12.5_
  - [ ] 11.5 Analytics aggregation module + wire Dashboard/Analytics real data + charts
    - NEW `frontend/admin-web/src/lib/analytics-aggregation.ts` (`aggregateOrders`: `statusCounts`, `ordersPerDay`, `revenuePerDay`; pure/deterministic)
    - EDIT `frontend/admin-web/src/pages/Dashboard.tsx`: replace the hardcoded metrics with `getAnalytics()` data; remove the `PendingFeature` banner; add recharts charts from `aggregateOrders(getOrders())`
    - EDIT `frontend/admin-web/src/pages/Analytics.tsx`: add the same charts; error state on failure (no fabricated numbers)
    - _Requirements: 17.1, 17.2, 17.3, 17.5, 17.6_
  - [ ]* 11.6 Property test: analytics aggregation determinism and totals
    - **Property 7: Analytics aggregation determinism and totals** (tag `Feature: ui-modernization, Property 7`)
    - **Validates: Requirements 17.3, 17.4**
  - [ ]* 11.7 Component tests: Dashboard/Analytics real data, charts, and placeholder removal (msw)
    - Assert real metrics render, the `$45,231.89` stub and `PendingFeature` are gone, and a failed fetch shows an error state
    - _Requirements: 17.1, 17.2, 17.5, 17.6_
  - [ ] 11.8 Orders page: react-query + auto-refresh + filter chips + search + actions
    - EDIT `frontend/admin-web/src/pages/Orders.tsx`: convert to `useQuery` with `refetchInterval`; add status filter chips and a search box; keep accept where `status ∈ {PENDING_PAYMENT, CONFIRMED}` and ready where `status == PREPARING`; invalidate on success
    - NEW `frontend/admin-web/src/lib/order-filter.ts` (`filterOrders`, pure)
    - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5, 16.6, 16.7_
  - [ ]* 11.9 Property test: order filter and search predicate
    - **Property 9: Order filter and search predicate** (tag `Feature: ui-modernization, Property 9`)
    - **Validates: Requirements 16.3, 16.4**
  - [ ]* 11.10 Component tests: Orders auto-refresh, chips, search, accept/ready (msw + fake timers)
    - _Requirements: 16.1, 16.2, 16.5, 16.6, 16.7_
  - [ ] 11.11 Restaurants: verify list, add detail view, verify status toggle
    - EDIT `frontend/admin-web/src/pages/Restaurants.tsx`: verify the list against the paginated `ApiResponse` shape; on a failed status update, show the error and keep the prior status
    - NEW `frontend/admin-web/src/pages/RestaurantDetail.tsx` + route in `frontend/admin-web/src/router.tsx`, consuming the existing `getRestaurant(id)`
    - No backend change: `PATCH /restaurants/{id}/status` already authorizes ADMIN (verified)
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_
  - [ ]* 11.12 Integration test: restaurant status toggle round-trip and error fallback (msw)
    - Toggle sends `PATCH {active}`; success refreshes the list; a 4xx keeps the prior status and surfaces an error
    - _Requirements: 13.3, 13.4, 13.5_
  - [ ] 11.13 Delivery Partners: add online/available/assigned filters and polish
    - EDIT `frontend/admin-web/src/pages/DeliveryPartners.tsx`: derive filters from `online` / `available` / `currentAssignmentId != null`; preserve the existing toggle/refresh behavior and shared table
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5_
  - [ ]* 11.14 Component test: partner filters and preserved behavior (msw)
    - _Requirements: 14.3, 14.5_
  - [ ] 11.15 Checkpoint - ensure theme, analytics, orders, restaurants, and partners pass
    - Ensure all tests pass, ask the user if questions arise.
  - [ ] 11.16 Live rider map: STOMP tracking client + LiveMap page + route + sidebar entry
    - NEW `frontend/admin-web/src/lib/tracking-url.ts` (`deriveTrackingWsUrl`) and `upsertRiders` (pure marker fold keyed by `riderId`, latest timestamp wins)
    - NEW `frontend/admin-web/src/services/tracking.ts` (`@stomp/stompjs` client to the derived ws URL with the admin JWT; subscribe `/topic/admin/riders/location`; reconnect with backoff)
    - NEW `frontend/admin-web/src/pages/LiveMap.tsx` (react-leaflet + OSM tiles; one moving marker per rider; rider count + last-seen; connection + non-blocking error state)
    - EDIT `frontend/admin-web/src/router.tsx` (add `/live-map`) and `frontend/admin-web/src/components/layout/Sidebar.tsx` (add nav entry, lucide `Map`/`MapPin`)
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6, 15.7, 15.9_
  - [ ]* 11.17 Property test: tracking WebSocket URL derivation
    - **Property 10: Tracking WebSocket URL derivation** (tag `Feature: ui-modernization, Property 10`)
    - **Validates: Requirements 15.2**
  - [ ]* 11.18 Property test: live-map marker upsert keyed by riderId
    - **Property 8: Live-map marker upsert keyed by riderId (latest wins)** (tag `Feature: ui-modernization, Property 8`)
    - **Validates: Requirements 15.4**
  - [ ]* 11.19 Component test: subscription parse, reconnect, and error state (fake STOMP client)
    - Feed fake frames; assert markers update, count/last-seen render, and a dropped/unauthorized socket shows the error state and retries
    - _Requirements: 15.3, 15.5, 15.6, 15.9_
  - [ ] 11.20 Gateway WebSocket auth for `/ws/tracking` (approval-gated backend change)
    - EDIT `backend/apiGateway/src/main/java/com/service/apiGateway/filter/JwtFilter.java`: for the `/ws/tracking/**` path, also read the JWT from a `token` query parameter, validate it, and inject the same `X-User-*` headers; leave the `Authorization`-header path unchanged for all other routes
    - Flag for approval before implementing; documented local-dev fallback is a direct connection to `:8087` (bypasses the gateway; insecure, not for production)
    - _Requirements: 15.8_
  - [ ]* 11.21 Accessibility and preserved-behavior tests
    - Run axe on key pages (no serious violations); assert semantic tables, accessible control names, and keyboard operability; assert the axios client attaches the Bearer token and that a 401 triggers logout + redirect to `/login`; assert the DeliveryPartners behavior is intact; check documented brand-on-surface pairs meet WCAG AA
    - _Requirements: 18.1, 18.2, 18.3, 18.4, 18.5, 18.6, 18.7_
  - [ ] 11.22 Final admin verification - build, lint, and test; fix issues before completion
    - Run `npm run build` (`tsc -b && vite build`), `npm run lint` (oxlint), and `vitest --run` in `frontend/admin-web`; fix any failures
    - IF task 11.20 was implemented, run `./mvnw -o compile` in `backend/apiGateway` (the only backend touched by the admin scope); otherwise no backend compile is required for the admin scope
    - Confirm preserved behavior: auth/session (Bearer attach, 401 → logout → `/login`) and the working DeliveryPartners page
    - Manual smoke (not automated): with the tracking + gateway services running, open the Live Map and confirm the STOMP handshake authorizes through the gateway and rider markers move on `/topic/admin/riders/location`
    - _Requirements: 12.1-12.7, 13.1-13.5, 14.1-14.5, 15.1-15.9, 16.1-16.7, 17.1-17.6, 18.1-18.7_

## Notes (admin scope)

- The admin group is **frontend-only** except for the optional, approval-gated gateway
  WebSocket-auth change (task 11.20). A2 (restaurants) requires **no** backend change because
  `PATCH /restaurants/{id}/status` already authorizes ADMIN (verified in `RestaurantController` and
  `RestaurantServiceImpl.assertOwner`).
- Admin property tests (Properties 7–10) reuse the same tagging/iteration conventions as Properties
  1–6 above.
- The live map (task 11.16) and the gateway ws-auth (task 11.20) are the only new-transport / new
  backend items; keep them last and verify the handshake manually (task 11.22).
- Preserve the working DeliveryPartners page and the auth/session flow throughout (Requirement 18).
