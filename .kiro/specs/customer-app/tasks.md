#Implementation Plan: Customer App

## Overview

This plan converts the Customer App design into incremental, test-driven coding tasks for the Flutter client under `frontend/Customer_app`. The build order lays the foundation first (scaffold → theme → error → network → storage → validation → models → routing/session), then implements vertical feature slices (authentication → discovery → restaurant → cart → checkout → orders → tracking → profile → addresses → favorites → notifications → settings), and finishes with cross-cutting polish (shared widgets, responsiveness, accessibility, performance) and an end-to-end integration test. Each task builds on the previous one and ends wired into the app — no orphaned code.

Conventions used below:
- State management: Riverpod with code generation (`@riverpod` + `riverpod_generator`); models with `freezed` + `json_serializable`; all generated via `build_runner` (one-shot: `dart run build_runner build --delete-conflicting-outputs`).
- Repositories return `Result<T>` = `Either<Failure, T>`; gap features (addresses, favorites, notifications, payment, profile edit, password recovery, live tracking) sit behind repository interfaces with local/polling implementations bound at the composition root.
- Sub-tasks marked `*` are optional tests and are not implemented automatically.
- Property tasks reference a design correctness property via `_Property: N_`; each is verified by a single `fast_check` property-based test running a minimum of 100 iterations, one property per test, tagged with a comment `// Feature: customer-app, Property {n}`.

## Tasks

- [x] 1. Scaffold the Flutter project and toolchain
  - Create the Flutter app at `frontend/Customer_app` with package name and `lib/` Clean Architecture layout (`core/`, `features/`, `bootstrap/`) per the design Folder Structure
  - Add `pubspec.yaml` dependencies (flutter_riverpod, riverpod_annotation, dio, go_router, flutter_secure_storage, shared_preferences, freezed_annotation, json_annotation, decimal, jwt_decoder, cached_network_image, shimmer, lottie, connectivity_plus, intl) and dev_dependencies (build_runner, riverpod_generator, freezed, json_serializable, riverpod_lint, custom_lint, flutter_lints, mocktail, http_mock_adapter, fast_check, flutter_test)
  - Configure `analysis_options.yaml` with `flutter_lints` + `custom_lint`/`riverpod_lint`; verify `build_runner` runs clean on an empty generated set
  - Create `lib/main.dart` (ProviderScope bootstrap), `lib/app.dart` (placeholder `MaterialApp`), and `lib/core/constants/` (base URL, default page size 10, 15s timeouts, durations)
  - Target: `frontend/Customer_app/` (`pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, `lib/app.dart`, `lib/core/constants/`)
  - _Requirements: 24.1, 26.1, 29.1_

  - [x] 1.1 Smoke test: app boots and analyzer is clean
    - Widget test that `App` pumps without exceptions; confirm `flutter analyze` passes
    - Target: `frontend/Customer_app/test/app_boot_test.dart`
    - _Requirements: 29.2_

- [x] 2. Implement core theme tokens and Material 3 light/dark themes
  - Create `AppTokens` `ThemeExtension` (color/semantic roles, per-`OrderStatus` palette, 4-pt spacing, radius, elevation) and a scalable `TextTheme`
  - Build `ThemeData` light and dark via `ColorScheme.fromSeed(seed, brightness)` with `useMaterial3: true`, attaching `AppTokens` to each; wire both into `app.dart` with a `ThemeMode` hook for later live switching
  - Target: `lib/core/theme/app_tokens.dart`, `lib/core/theme/app_theme.dart`, `lib/core/theme/theme_extensions.dart`, `lib/app.dart`
  - _Requirements: 29.1, 29.2, 29.3, 28.2, 28.3_
  - _Property: 24_

  - [x] 2.1 Property test: body-text contrast ratio ≥ 4.5:1
    - Generate body-text foreground/background role pairs from tokens; assert WCAG contrast ≥ 4.5:1 in both light and dark themes
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 24`
    - Target: `frontend/Customer_app/test/core/theme/contrast_property_test.dart`
    - _Requirements: 28.3_
    - _Property: 24_

- [x] 3. Implement core error model and Result type
  - Define the sealed `AppException` hierarchy (NoConnection, Timeout, Unauthorized, Server, Client w/ fieldErrors, ApiEnvelope, Unknown)
  - Define the sealed UI-facing `Failure` hierarchy (NoConnection, Timeout, Server, Validation w/ fieldErrors, Conflict, RateLimit, InvalidCredentials, SessionExpired, Unknown)
  - Define `Result<T>` = `Either<Failure, T>` typedef plus helpers (`getOrThrow`, fold/map helpers)
  - Target: `lib/core/error/app_exception.dart`, `lib/core/error/failure.dart`, `lib/core/error/result.dart`
  - _Requirements: 23.1, 23.2, 23.3, 23.4, 24.2_

- [x] 4. Implement the networking layer (Dio, interceptors, ApiClient, decoders)
  - [x] 4.1 Create the Dio provider and ordered interceptor chain
    - Build one `Dio` singleton with 15s connect/receive/send timeouts; register interceptors in order: Auth → Logging → Retry → Unauthorized(401 seam) → Error
    - Define small composition-root ports the interceptors depend on: a `TokenStore` (read/clear) and an `AuthEventSink` (emit `SessionExpired`), bound later by storage (task 5) and session (task 8); provide temporary in-memory bindings so the chain compiles and is testable now
    - AuthInterceptor attaches `Authorization: Bearer <token>` only when the path is not under `/auth/`; force HTTPS in non-local builds
    - UnauthorizedInterceptor is the single 401 seam (`QueuedInterceptor`): on a non-`/auth/**` 401 it clears the token via `TokenStore` and emits `SessionExpired`; `/auth/**` 401s pass through
    - RetryInterceptor: bounded exponential backoff for idempotent GET on timeout/transient errors only (never 4xx)
    - ErrorInterceptor converts any `DioException` into a typed `AppException`
    - Target: `lib/core/network/dio_provider.dart`, `lib/core/network/interceptors/{auth,logging,retry,unauthorized,error}_interceptor.dart`
    - _Requirements: 3.3, 4.1, 4.3, 23.2, 23.3, 25.3, 25.4_

  - [x] 4.2 Implement ApiClient, envelope/page decoders, and cancellation
    - Build `ApiClient` with typed helpers: `getEnvelope`/`getEnvelopePage` (restaurant service `ApiResponse<T>`), `getJson`/`postJson`/`patchJson` (bare order-service bodies), all accepting a `CancelToken`
    - Implement `ApiResponse<T>` decoder (`{success,message,data}`; raise `ApiEnvelopeException(message)` when `success == false`) and Spring `Page<T>` decoder (`content[]`, `number`, `size`, `totalElements`, `totalPages`, `last`, `first`) into a generic `PageResult<T>`
    - Target: `lib/core/network/api_client.dart`, `lib/core/network/api_response.dart`, `lib/core/network/page_response.dart`
    - _Requirements: 24.1, 24.2, 24.3, 23.8_

  - [x] 4.3 Implement the pure exception→failure mapper
    - Map each transport outcome (no-connectivity, timeout, 5xx, 4xx≠401, 409, 429, envelope `success==false`) to exactly one `Failure`, preserving the server field-error map for 400
    - Target: `lib/core/error/error_mapper.dart`
    - _Requirements: 1.6, 23.1, 23.2, 23.3, 23.4, 24.2_
    - _Property: 3_

  - [x] 4.4 Property test: authorization header attachment
    - For any request path, assert `Authorization` header is attached iff the path is not under `/auth/`
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 4`
    - Target: `frontend/Customer_app/test/core/network/auth_header_property_test.dart`
    - _Requirements: 3.3, 25.3_
    - _Property: 4_

  - [x] 4.5 Property test: failure classification mapping
    - For any transport outcome, assert exactly one corresponding `Failure` is produced and no server field-error entry is lost
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 3`
    - Target: `frontend/Customer_app/test/core/network/failure_mapping_property_test.dart`
    - _Requirements: 1.6, 23.1, 23.2, 23.3, 23.4, 24.2_
    - _Property: 3_

  - [x] 4.6 Property test: sensitive value redaction in logs
    - For any log record embedding a JWT or password, assert the logged output never contains the token/password value
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 22`
    - Target: `frontend/Customer_app/test/core/network/redaction_property_test.dart`
    - _Requirements: 25.2_
    - _Property: 22_

- [x] 5. Implement core storage wrappers and bind the token store
  - Create a `flutter_secure_storage` wrapper for the JWT (read/write/clear) and a `SharedPreferences` wrapper for non-sensitive prefs (theme mode)
  - Bind the network `TokenStore` port (task 4) to the secure-storage-backed implementation via a provider override at the composition root
  - Target: `lib/core/storage/secure_storage.dart`, `lib/core/storage/preferences.dart`
  - _Requirements: 25.1, 25.4, 22.1_

  - [x] 5.1 Unit tests for storage wrappers
    - Verify token read/write/clear and prefs read/write using fakes
    - Target: `frontend/Customer_app/test/core/storage/storage_test.dart`
    - _Requirements: 25.1, 25.4_

- [x] 6. Implement input validators
  - Create pure validators: email well-formedness; password length (8–25 register, 8–15 login); non-blank full name (reject whitespace-only); phone `^[6-9]\d{9}$`
  - Expose a combined submit-gate function for registration and for login
  - Target: `lib/core/validation/validators.dart`
  - _Requirements: 1.1, 1.3, 2.1_
  - _Property: 2_

  - [x] 6.1 Property test: registration/login validation gating
    - For any registration field set, submittable iff email valid AND password 8–25 AND name non-blank AND phone matches; for any login set, submittable iff email valid AND password 8–15
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 2`
    - Target: `frontend/Customer_app/test/core/validation/validation_property_test.dart`
    - _Requirements: 1.1, 1.3, 2.1_
    - _Property: 2_

- [x] 7. Implement DTO models, domain entities, and mappers
  - [x] 7.1 Create freezed/json_serializable DTOs mirroring backend wire shape
    - Implement `AuthResponseDto`, `UserResponseDto`, `RestaurantDto`, `CategoryDto`, `MenuItemDto`, `PageDto<T>`, `ApiResponseDto<T>`, `OrderDto`, `OrderItemDto`, `DeliveryLocationDto`, `CreateOrderDto`, `CreateOrderItemDto` with exact field names/nullability per the DTO catalog
    - Add `DecimalJsonConverter` for money (`price`, `subtotal`, `deliveryFee`, `tax`, `totalAmount`, `totalPrice`) reading number-or-string and writing canonical string; keep temporal fields as raw `String`; tolerant `OrderStatus` decoder routing unknown values to a safe `unknown` sentinel; run `build_runner`
    - Target: `lib/features/**/data/dtos/`, `lib/core/network/` (shared `PageDto`, `ApiResponseDto`), `lib/core/utils/decimal_converter.dart`
    - _Requirements: 24.1, 24.3_

  - [x] 7.2 Create domain entities and DTO↔entity mappers
    - Implement entities (`Restaurant`, `MenuCategory`, `MenuItem`, `PageResult<T>`, `Order`, `OrderItem`, `DeliveryLocation`, `UserAccount`) and mappers parsing raw temporals to `TimeOfDay`/`DateTime` and applying nullable defaults (e.g. `categories`→`[]`, `available`/`vegetarian`→`false`)
    - Target: `lib/features/**/domain/entities/`, `lib/features/**/data/mappers/`
    - _Requirements: 24.1, 24.3, 10.2_
    - _Property: 1_

  - [x] 7.3 Property test: serialization round-trip
    - For any restaurant/category/menu-item/page/order/order-item/delivery-location model, assert `fromJson(toJson(model)) == model` with money exact via `Decimal` and temporals preserved as raw strings
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 1`
    - Target: `frontend/Customer_app/test/data/serialization_round_trip_property_test.dart`
    - _Requirements: 24.1, 24.3, 24.4_
    - _Property: 1_

- [x] 8. Implement routing, session repository, and startup guard
  - [x] 8.1 Implement SessionRepository and identity-claims decoding
    - Implement `SessionRepository` (`currentSession`, `persist`, `clear`, `changes()` stream, `claims()`); decode JWT via `jwt_decoder` into `IdentityClaims{id,email,role,name,phone,exp}`; treat expired tokens as unauthenticated
    - Bind the network `AuthEventSink`/`TokenStore` (task 4/5) so the 401 seam clears this session and emits `SessionExpired`
    - Target: `lib/features/authentication/domain/` (interfaces, `Session`, `IdentityClaims`), `lib/features/authentication/data/session_repository_impl.dart`
    - _Requirements: 3.4, 3.5, 4.1, 4.3, 5.1, 25.4_
    - _Property: 5_

  - [x] 8.2 Implement GoRouter table, redirect guard, and app-start bootstrap
    - Build the route table (`/splash`, `/login`, `/register`, `/forgot-password`, protected `ShellRoute` for `/home`,`/orders`,`/favorites`,`/profile`, plus `/search`,`/restaurant/:id`,`/cart`,`/checkout`,`/tracking/:orderId`,`/addresses`,`/notifications`,`/settings`)
    - Implement the `redirect` guard with `refreshListenable` bridged from `SessionRepository.changes()`; implement `app_startup` bootstrap that routes to `/home` when a valid token exists and `/login` otherwise
    - Target: `lib/core/routing/app_router.dart`, `lib/core/routing/routes.dart`, `lib/bootstrap/app_startup.dart`, `lib/app.dart`
    - _Requirements: 3.1, 3.2, 3.5, 4.1, 21.3_
    - _Property: 6_

  - [x] 8.3 Property test: identity-claims decode round-trip
    - For any claim set, encoding into a JWT payload then decoding yields an equal claim set
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 5`
    - Target: `frontend/Customer_app/test/features/authentication/claims_round_trip_property_test.dart`
    - _Requirements: 3.4_
    - _Property: 5_

  - [x] 8.4 Property test: startup session route decision
    - For any (token-present, token-expired) combination, resolve to `/home` iff token present and not expired, else `/login`
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 6`
    - Target: `frontend/Customer_app/test/features/authentication/startup_route_property_test.dart`
    - _Requirements: 3.1, 3.2, 3.5_
    - _Property: 6_

- [x] 9. Checkpoint - core foundation
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Implement the authentication feature
  - [x] 10.1 Implement AuthRepository and remote data source
    - Implement `AuthRemoteDataSource` and `AuthRepositoryImpl` for `POST /auth/register/customer` and `POST /auth/login/customer`; on login success persist the session via `SessionRepository`; map 201→success, 409→Conflict, 429→RateLimit, 401→InvalidCredentials, 400→Validation(fieldErrors)
    - Target: `lib/features/authentication/data/` (datasource, `auth_repository_impl.dart`)
    - _Requirements: 1.1, 1.2, 1.4, 1.5, 1.6, 2.1, 2.2, 2.3, 2.4_

  - [x] 10.2 Implement login, register, and flagged forgot-password screens
    - Build Login and Register screens with `AuthController` (`AsyncNotifier`), field-level validation messages, loading state that disables and blocks duplicate submit, and route-to-login on register success
    - Implement `PasswordRecoveryRepository` (throws `FeatureUnavailable`) and render forgot-password/OTP screens disabled ("coming soon"); implement logout that calls `SessionRepository.clear()` and resets the navigation stack
    - Target: `lib/features/authentication/presentation/` (screens + controllers)
    - _Requirements: 1.2, 1.3, 1.6, 2.2, 2.3, 2.4, 2.5, 5.1, 5.2, 6.1, 6.2, 6.3_

  - [x] 10.3 Unit/widget tests for auth flows
    - Test 201→success+route, 409 duplicate, 429 rate-limit, 401 invalid-credentials, 400 field mapping, loading disables submit, forgot-password disabled state, logout clears session and stack
    - Target: `frontend/Customer_app/test/features/authentication/`
    - _Requirements: 1.2, 1.4, 1.5, 1.6, 2.2, 2.3, 2.4, 2.5, 5.1, 5.2, 6.2_

- [x] 11. Implement the home/discovery feature
  - [x] 11.1 Implement RestaurantRepository list/search and discovery controllers
    - Implement `RestaurantRemoteDataSource` + `RestaurantRepositoryImpl` for `GET /restaurants` (size 10, optional `city`/`category`) and `GET /restaurants/search` (keyword, size 10) returning `PageResult<Restaurant>`
    - Implement `HomeFeed` (`AsyncNotifier`, append pages, concurrency-guarded), `RestaurantSearch` (400ms debounce, supersede-cancel via `CancelToken`), and `DiscoveryFilters` (`Notifier`, city/category)
    - Target: `lib/features/home/data/`, `lib/features/home/presentation/` (controllers)
    - _Requirements: 7.1, 7.4, 7.5, 8.1, 8.2, 26.1_

  - [x] 11.2 Implement pagination accumulation, prefetch, and recommended ordering
    - Implement pure pagination accumulation (in-order concatenation; stop when `last` true) and a prefetch predicate (trigger when visible index within 3 of end and `last` false); implement recommended ordering = sort by rating descending with stable placement for missing ratings
    - Target: `lib/features/home/domain/` (pagination + recommended helpers)
    - _Requirements: 7.3, 8.3, 9.1, 26.1, 26.4_
    - _Property: 8, 9_

  - [x] 11.3 Build home and search screens with filters and recommended/promotions sections
    - Build Home screen (recommended section, curated promotions content, paginated infinite-scroll list showing name/cuisine/rating/avg delivery time/open status) and Search screen; derive filter-chip catalog client-side from loaded data; navigate to restaurant detail on selection; render distinct empty states
    - Target: `lib/features/home/presentation/` (screens)
    - _Requirements: 7.2, 7.6, 8.3, 8.4, 9.2, 9.3_

  - [x] 11.4 Property test: discovery filter query-parameter inclusion
    - For any city/category state, request includes `city` iff a city filter is set and `category` iff a category filter is set
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 7`
    - Target: `frontend/Customer_app/test/features/home/filter_query_property_test.dart`
    - _Requirements: 7.4, 7.5_
    - _Property: 7_

  - [x] 11.5 Property test: pagination accumulation and prefetch
    - For any sequence of pages, accumulated list equals in-order concatenation, advancement stops at `last`, and prefetch triggers iff within 3 of end and not last
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 8`
    - Target: `frontend/Customer_app/test/features/home/pagination_property_test.dart`
    - _Requirements: 7.3, 8.3, 26.1, 26.4_
    - _Property: 8_

  - [x] 11.6 Property test: recommended ordering by rating
    - For any restaurant list, recommended section is a permutation ordered by rating descending with defined placement for missing ratings
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 9`
    - Target: `frontend/Customer_app/test/features/home/recommended_property_test.dart`
    - _Requirements: 9.1_
    - _Property: 9_

  - [x] 11.7 Unit/widget tests for discovery
    - Test debounce timing, supersede-cancel, empty-state rendering, and navigation to detail
    - Target: `frontend/Customer_app/test/features/home/`
    - _Requirements: 8.1, 8.2, 7.6, 8.4, 9.3_

- [x] 12. Implement the restaurant detail and menu feature
  - [x] 12.1 Implement menu retrieval and detail controller
    - Implement `RestaurantRepository.getMenu` (`GET /restaurants/{id}/menu`) and `getById` (`GET /restaurants/{id}`); implement `restaurantMenu(id)` family `AsyncNotifier`
    - Implement pure helpers: category grouping (flatten preserves item multiset) and in-menu case-insensitive name/description filter
    - Target: `lib/features/restaurant/data/`, `lib/features/restaurant/domain/`, `lib/features/restaurant/presentation/` (controller)
    - _Requirements: 10.1, 10.2, 10.5_
    - _Property: 10, 11_

  - [x] 12.2 Build restaurant detail + menu screen
    - Render header info, read-only rating, and menu grouped by category with name/description/price/veg indicator/availability; disable unavailable items (block add-to-cart); wire the in-menu search field
    - Target: `lib/features/restaurant/presentation/` (screen)
    - _Requirements: 10.2, 10.3, 10.4, 10.5_

  - [x] 12.3 Property test: in-menu search filtering
    - For any menu and search text, filtered items are exactly those whose name or description contains the text (case-insensitive)
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 10`
    - Target: `frontend/Customer_app/test/features/restaurant/menu_filter_property_test.dart`
    - _Requirements: 10.5_
    - _Property: 10_

  - [x] 12.4 Property test: menu category grouping preserves items
    - For any menu, flattening category-grouped items yields the same multiset as the source items (none lost/duplicated/reassigned)
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 11`
    - Target: `frontend/Customer_app/test/features/restaurant/menu_grouping_property_test.dart`
    - _Requirements: 10.2_
    - _Property: 11_

- [x] 13. Implement the cart feature
  - [x] 13.1 Implement the persistent local CartRepository and cart logic
    - Implement `Cart` model and `CartRepository` local implementation that persists across restarts (storage-backed); add item stores menuItemId/itemName/quantity≥1; quantity change updates; quantity-to-zero removes; block adding unavailable items; enforce single-restaurant invariant with replace-cart confirmation; compute line totals and subtotal with `Decimal`
    - Target: `lib/features/cart/domain/` (`Cart`, interface), `lib/features/cart/data/cart_repository_impl.dart`
    - _Requirements: 10.4, 11.1, 11.2, 11.3, 11.4, 12.1, 12.2_
    - _Property: 12, 13_

  - [x] 13.2 Build cart review screen with display-only pricing
    - Build Cart screen with `CartController` (kept-alive `Notifier`): per-item name/unit price/quantity/line total, indicative subtotal/fee/tax/total labeled subject to server confirmation, a no-op coupon input, replace-cart confirmation dialog, empty-cart message disabling checkout, enable checkout when non-empty
    - Target: `lib/features/cart/presentation/`
    - _Requirements: 11.2, 12.1, 12.2, 12.3, 12.4, 12.5_

  - [x] 13.3 Property test: cart math and state transitions
    - For any cart and available item: add stores id/name/qty≥1; quantity change updates; zero removes; line total = unit price × qty; subtotal = sum of line totals (Decimal); adding an unavailable item leaves the cart unchanged
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 12`
    - Target: `frontend/Customer_app/test/features/cart/cart_math_property_test.dart`
    - _Requirements: 10.4, 11.1, 11.3, 11.4, 12.1, 12.2_
    - _Property: 12_

  - [x] 13.4 Property test: cart single-restaurant invariant
    - For any sequence of adds, all cart items share one restaurant id; confirming replace yields a cart with only the new restaurant's items
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 13`
    - Target: `frontend/Customer_app/test/features/cart/cart_invariant_property_test.dart`
    - _Requirements: 11.2_
    - _Property: 13_

- [x] 14. Implement the checkout feature
  - [x] 14.1 Implement address/payment/order repositories for checkout
    - Implement `DeliveryAddress` model + `AddressRepository` interface and local implementation (all/save/delete/setDefault/defaultAddress) used by checkout selection and add-at-checkout
    - Implement `PaymentRepository` (no-op approval, swappable) and `OrderRepository.placeOrder` (`POST /orders`) returning the server `OrderResponse`
    - Build the `POST /orders` body from cart + selected `Delivery_Location` containing restaurantId, deliveryLocation{address,latitude,longitude}, deliveryAddress, and items[menuItemId,itemName,quantity] — excluding any customer identifier
    - Target: `lib/features/addresses/domain/` + `lib/features/addresses/data/` (address repo), `lib/features/checkout/data/` (payment + order repos), `lib/features/checkout/domain/` (`PlaceOrderParams`)
    - _Requirements: 13.1, 13.2, 13.4, 15.1, 15.2_
    - _Property: 15_

  - [x] 14.2 Implement CheckoutController orchestration and place-order with auto-confirm polling
    - Implement `CheckoutController` orchestrating address → payment step → place order; on payment confirm, place the order (no client payment call) and poll order status until it leaves `PENDING_PAYMENT` (normally `CONFIRMED`, or `FAILED`); treat server status as authoritative payment outcome
    - On 201 clear the cart and route to `/tracking/:orderId`, showing server-computed pricing as authoritative; on 400 keep cart intact and show the server message
    - Implement the placement-gating predicate (enabled iff cart non-empty AND address selected)
    - Target: `lib/features/checkout/presentation/` (controller), `lib/features/checkout/domain/` (gating helper)
    - _Requirements: 12.4, 12.5, 13.3, 14.1, 14.2, 14.3, 14.4, 15.3, 15.4, 15.5_
    - _Property: 14_

  - [x] 14.3 Build checkout screens (address selection → payment step → place)
    - Build address-selection step (list local addresses, populate Delivery_Location + delivery-address text, add-new persists and selects), payment step behind `PaymentRepository`, and confirm/place step; disable placement and prompt when no address selected
    - Target: `lib/features/checkout/presentation/` (screens)
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 14.1_

  - [x] 14.4 Property test: checkout placement gating
    - For any cart/address combination, the proceed/place control is enabled iff the cart is non-empty and an address is selected
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 14`
    - Target: `frontend/Customer_app/test/features/checkout/placement_gating_property_test.dart`
    - _Requirements: 12.4, 12.5, 13.3_
    - _Property: 14_

  - [x] 14.5 Property test: order request body excludes customer identity
    - For any non-empty cart and selected address, the `POST /orders` body contains restaurantId, deliveryLocation, deliveryAddress, and mapped items, and contains no customer-identifier field
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 15`
    - Target: `frontend/Customer_app/test/features/checkout/order_body_property_test.dart`
    - _Requirements: 13.2, 15.1, 15.2_
    - _Property: 15_

  - [x] 14.6 Unit/widget tests for checkout
    - Test 201 clears cart + routes to tracking, server pricing authoritative, 400 keeps cart, and PENDING_PAYMENT→CONFIRMED poll loop with mocked Dio
    - Target: `frontend/Customer_app/test/features/checkout/`
    - _Requirements: 14.3, 15.3, 15.4, 15.5_

- [x] 15. Checkpoint - commerce flow (auth → discovery → cart → checkout)
  - Ensure all tests pass, ask the user if questions arise.

- [x] 16. Implement the orders history feature
  - [x] 16.1 Implement myOrders retrieval and order-status interpretation
    - Implement `OrderRepository.myOrders` (`GET /orders/my-orders`) and `MyOrders` (`AsyncNotifier`)
    - Implement the shared order-status interpretation: Active iff status not `DELIVERED`/`CANCELLED`/`FAILED` (else Previous, total partition); total lifecycle representation for all 9 statuses; customer-cancellable set predicate (reused by tracking)
    - Target: `lib/features/orders/data/`, `lib/features/orders/domain/order_status_logic.dart`, `lib/features/orders/presentation/` (controller)
    - _Requirements: 16.1, 16.2, 16.3, 17.2, 17.6_
    - _Property: 16_

  - [x] 16.2 Build order history screen with active/previous sections
    - Render Active and Previous sections, navigate to tracking on selection, and show a distinct empty state
    - Target: `lib/features/orders/presentation/` (screen)
    - _Requirements: 16.2, 16.4, 16.5_

  - [x] 16.3 Property test: order status interpretation
    - For any status: Active/Previous partition is exact and total; the 9-status lifecycle mapping is total; the cancel control shows iff status is in the cancellable set
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 16`
    - Target: `frontend/Customer_app/test/features/orders/order_status_property_test.dart`
    - _Requirements: 16.2, 16.3, 17.2, 17.6_
    - _Property: 16_

- [x] 17. Implement the order tracking feature
  - [x] 17.1 Implement the polling tracking stream and cancel
    - Implement `OrderTrackingRepository.track(orderId)` polling implementation: emit immediately, re-fetch `GET /orders/{orderId}` every 15s, and complete the stream at the first terminal status (`DELIVERED`/`CANCELLED`/`FAILED`); implement `OrderRepository.cancel` (`PATCH /orders/{orderId}/cancel`)
    - Implement `OrderTracking(orderId)` controller consuming the stream and exposing cancel
    - Target: `lib/features/tracking/data/polling_order_tracking_repository.dart`, `lib/features/tracking/presentation/` (controller), `lib/features/checkout/data/` (cancel in order repo)
    - _Requirements: 17.1, 17.3, 17.4, 17.5, 17.6_
    - _Property: 17_

  - [x] 17.2 Build tracking screen with full lifecycle timeline and cancel
    - Render the current status and an `OrderStatusTimeline` covering all 9 statuses (including terminal CANCELLED/FAILED branch); present the cancel control only for cancellable states; on cancel error keep current status and show the server message
    - Target: `lib/features/tracking/presentation/` (screen)
    - _Requirements: 17.1, 17.2, 17.6, 17.7_

  - [x] 17.3 Property test: tracking stream stops at terminal status
    - For any sequence of statuses, the stream emits until the first terminal status and stops exactly there — not before, not after
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 17`
    - Target: `frontend/Customer_app/test/features/tracking/tracking_stream_property_test.dart`
    - _Requirements: 17.4_
    - _Property: 17_

  - [x] 17.4 Unit tests for tracking cadence and cancel
    - Test 15s polling cadence (fake timers) and cancel-error retains displayed status
    - Target: `frontend/Customer_app/test/features/tracking/`
    - _Requirements: 17.3, 17.7_

- [x] 18. Implement the profile feature
  - Implement `ProfileRepository` (claims-backed `get()`; `update()` throws `FeatureUnavailable`) and a `ProfileController`; build the profile screen showing name/email/phone/role from `IdentityClaims` with edit controls disabled ("not yet available")
  - Target: `lib/features/profile/data/`, `lib/features/profile/presentation/`
  - _Requirements: 18.1, 18.2, 18.3_

  - [x] 18.1 Widget tests for profile
    - Test claims-driven display and disabled edit controls
    - Target: `frontend/Customer_app/test/features/profile/`
    - _Requirements: 18.1, 18.2_

- [x] 19. Implement the saved addresses feature
  - Build the address management screen (list/add/delete/set-default) with `AddressController` over the local `AddressRepository` from task 14; persist address text/lat/lng locally; mark exactly one default; feed checkout selection
  - Target: `lib/features/addresses/presentation/`
  - _Requirements: 13.4, 19.1, 19.2, 19.3, 19.4, 19.5_
  - _Property: 18_

  - [x] 19.1 Property test: address store round-trip, deletion, single default
    - For any sequence of operations, read-back returns exactly the saved set; deletion removes only the target; after set-default exactly one address is default
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 18`
    - Target: `frontend/Customer_app/test/features/addresses/address_store_property_test.dart`
    - _Requirements: 13.4, 19.1, 19.2, 19.3, 19.4_
    - _Property: 18_

- [x] 20. Implement the favorites feature
  - Implement `FavoriteRef` model and local `FavoritesRepository` (add idempotent, remove, `watch()`); build the favorites grid resolving stored ids via `GET /restaurants/{id}` with `FavoritesController`; wire favorite toggle on restaurant cards
  - Target: `lib/features/favorites/domain/`, `lib/features/favorites/data/`, `lib/features/favorites/presentation/`
  - _Requirements: 20.1, 20.2, 20.3, 20.4_
  - _Property: 19_

  - [x] 20.1 Property test: favorites add idempotence and removal
    - For any sequence, adding makes an id present, re-adding leaves the set unchanged (idempotence), removing makes it absent; read-back returns exactly the resulting set
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 19`
    - Target: `frontend/Customer_app/test/features/favorites/favorites_property_test.dart`
    - _Requirements: 20.1, 20.2_
    - _Property: 19_

- [x] 21. Implement the notifications feature
  - Implement `AppNotification` model and local `NotificationRepository` (`store`, `history`, `watch()` reverse-chronological); write push receipts into the store; build the notifications screen and deep-link order notifications to `/tracking/:orderId`
  - Target: `lib/features/notifications/domain/`, `lib/features/notifications/data/`, `lib/features/notifications/presentation/`
  - _Requirements: 21.1, 21.2, 21.3, 21.4_
  - _Property: 20_

  - [x] 21.1 Property test: notifications reverse-chronological ordering
    - For any set of stored notifications, the displayed list is a permutation ordered by received-time descending
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 20`
    - Target: `frontend/Customer_app/test/features/notifications/notifications_order_property_test.dart`
    - _Requirements: 21.2_
    - _Property: 20_

  - [x] 21.2 Widget test for notification deep-link
    - Test that opening an order notification routes to tracking
    - Target: `frontend/Customer_app/test/features/notifications/`
    - _Requirements: 21.3_

- [x] 22. Implement the settings and theme selection feature
  - Implement `SettingsRepository` over prefs and a `ThemeModeController`; build the settings screen (light/dark/system); default to system when unset; apply the selected theme app-wide live by wiring the controller into `app.dart`'s `ThemeMode`
  - Target: `lib/features/settings/data/`, `lib/features/settings/presentation/`, `lib/app.dart`
  - _Requirements: 22.1, 22.2, 22.3_
  - _Property: 21_

  - [x] 22.1 Property test: theme preference round-trip and default
    - For any selected mode, persist-then-read returns the same mode; resolved startup theme is the stored mode when present and system when absent
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 21`
    - Target: `frontend/Customer_app/test/features/settings/theme_pref_property_test.dart`
    - _Requirements: 22.1, 22.2_
    - _Property: 21_

- [x] 23. Checkpoint - all features implemented
  - Ensure all tests pass, ask the user if questions arise.

- [x] 24. Extract and standardize the shared widget catalog
  - Build `core/widgets/` catalog (PrimaryButton/SecondaryButton with loading + ≥48px target, AppTextField with inline validation, AppCard, RestaurantCard, MenuItemTile, OrderCard, OrderStatusChip, OrderStatusTimeline, QuantityStepper, RatingView, AppSearchBar, SkeletonList/Shimmer*, EmptyState, ErrorStateView, NoConnectionView, AppDialog/AppBottomSheet, AppSnackbar)
  - Refactor feature screens to consume the shared widgets; standardize the `AsyncValue` rendering pattern (loading→shimmer, empty→EmptyState distinct from error, Failure→ErrorStateView with retry via `ref.invalidate`, no-connection→NoConnectionView)
  - Target: `lib/core/widgets/`, feature `presentation/` screens
  - _Requirements: 23.1, 23.3, 23.5, 23.6, 23.7, 26.2_

  - [x] 24.1 Widget tests for shared states
    - Test loading/empty/error/no-connection rendering and retry reissues the request
    - Target: `frontend/Customer_app/test/core/widgets/`
    - _Requirements: 23.5, 23.6, 23.7_

- [x] 25. Implement responsiveness, accessibility, and performance polish
  - [x] 25.1 Implement responsive column selection and adaptive layout
    - Implement the pure `columnsForWidth(width)` (1 below tablet breakpoint, >1 at/above, non-decreasing) and `AdaptiveListGrid`; apply to restaurant/menu lists; preserve controller state across orientation changes
    - Target: `lib/core/widgets/adaptive_list_grid.dart`, `lib/core/utils/responsive.dart`
    - _Requirements: 27.1, 27.2, 27.3_
    - _Property: 23_

  - [x] 25.2 Apply accessibility and image/performance refinements
    - Add semantic labels to interactive controls and informational images, ensure ≥48×48 touch targets and scalable text, enforce list virtualization (`ListView.builder`/`GridView.builder`), and integrate `cached_network_image` for restaurant/menu images
    - Target: feature `presentation/` screens, `lib/core/widgets/`
    - _Requirements: 26.3, 28.1, 28.2, 28.4_

  - [x] 25.3 Property test: responsive column selection
    - For any width, columns = 1 below breakpoint and >1 at/above, and the column-count function is non-decreasing in width
    - `fast_check`, ≥100 iterations, one property per test; tag `// Feature: customer-app, Property 23`
    - Target: `frontend/Customer_app/test/core/responsive_columns_property_test.dart`
    - _Requirements: 27.1, 27.2_
    - _Property: 23_

  - [x] 25.4 Accessibility example tests
    - Test semantic labels presence, touch-target sizes, and text scaling response
    - Target: `frontend/Customer_app/test/core/accessibility/`
    - _Requirements: 28.1, 28.2, 28.4_

- [x] 26. Final integration and end-to-end wiring
  - Verify the composition root binds all repositories/providers (interfaces→implementations), the router shell + bottom navigation, and theme/session listenables; confirm no feature depends on the data layer directly
  - Target: `lib/main.dart`, `lib/app.dart`, `lib/core/routing/app_router.dart`, provider bindings across `lib/features/**`
  - _Requirements: 3.1, 4.1, 22.3, 29.3_

  - [x] 26.1 Integration happy-path test (mocked Dio)
    - End-to-end login → browse → add to cart → checkout → place order → tracking with `http_mock_adapter`; advance mocked order status `PENDING_PAYMENT`→`CONFIRMED` and assert the order reaches `CONFIRMED`
    - Target: `frontend/Customer_app/integration_test/happy_path_test.dart`
    - _Requirements: 14.2, 14.3, 15.3, 17.1_

- [x] 27. Final checkpoint - full suite
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional test sub-tasks and can be skipped for a faster MVP; core implementation sub-tasks are never optional.
- Each task references granular requirement clauses for traceability; `_Property: N_` links a task to its design correctness property.
- All 24 design correctness properties are covered: Property 1 (task 7), 2 (task 6), 3/4/22 (task 4), 5/6 (task 8), 7/8/9 (task 11), 10/11 (task 12), 12/13 (task 13), 14/15 (task 14), 16 (task 16), 17 (task 17), 18 (task 19), 19 (task 20), 20 (task 21), 21 (task 22), 23 (task 25), 24 (task 2).
- Property tests use `fast_check` with ≥100 iterations, one property per test, tagged `// Feature: customer-app, Property {n}`; network code is tested with mocked Dio (`http_mock_adapter`/`mocktail`) and repositories bound via Riverpod provider overrides.
- Checkpoints (tasks 9, 15, 23, 27) provide incremental validation points.
- Scope is the Customer App only; the Delivery and Admin clients are out of scope. No new backend endpoints are introduced — checkout places the order via `POST /orders` and polls order status until it leaves `PENDING_PAYMENT`.
