# Implementation Plan — Delivery Partner App

## Overview

This plan converts the Delivery Partner App design into incremental, test-driven coding tasks for the Flutter client under `frontend/Delivery_app`. The build order lays the foundation first (scaffold → theme → error → network → storage → validators → models → routing/session), implements vertical feature slices (auth → availability → location core → background location → push notifications → assignment lifecycle → maps/navigation → history → earnings → profile → notifications → settings), then finishes with lifecycle handling, offline-queue hardening, and an end-to-end integration test.

Each task builds on the previous one and ends wired into the running app. No orphaned code.

**Conventions:**
- State management: Riverpod with `@riverpod` code generation; models with `freezed` + `json_serializable`; generated via `build_runner`.
- Repositories return `Result<T>` = `Either<Failure, T>`; gap features sit behind interfaces with local implementations.
- Sub-tasks marked `*` are optional/test tasks and are not implemented automatically.
- Property tasks reference `_Property: N_`; each verified by a `fast_check` property-based test, ≥100 iterations, tagged `// Feature: delivery-app, Property {n}`.

---

## Tasks

- [ ] 1. Scaffold the Flutter project and toolchain
  - Create the Flutter app at `frontend/Delivery_app` with the Clean Architecture layout (`core/`, `features/`, `bootstrap/`) matching the design Folder Structure
  - Add `pubspec.yaml` dependencies: flutter_riverpod, riverpod_annotation, riverpod_generator, dio, go_router, flutter_secure_storage, shared_preferences, freezed_annotation, json_annotation, decimal, jwt_decoder, cached_network_image, shimmer, lottie, connectivity_plus, intl, permission_handler, geolocator, google_maps_flutter, firebase_core, firebase_messaging, flutter_local_notifications, flutter_foreground_task, background_fetch, url_launcher, sqflite, path_provider
  - Add dev_dependencies: build_runner, freezed, json_serializable, riverpod_lint, custom_lint, flutter_lints, mocktail, http_mock_adapter, fast_check, flutter_test
  - Configure `analysis_options.yaml` with `flutter_lints` + `riverpod_lint`; verify `build_runner` runs clean
  - Create `lib/main.dart` (ProviderScope bootstrap + Firebase init + FCM background handler registration), `lib/app.dart` (placeholder MaterialApp), `lib/core/constants/` (base URL, heartbeat interval 10s, distance filter 15m, max retries 3, 15s timeouts)
  - Add platform configuration: Google Maps API key in `AndroidManifest.xml` and `AppDelegate.swift`/`Info.plist`; add all required permissions and background modes (see design.md)
  - Target: `frontend/Delivery_app/` (pubspec.yaml, analysis_options.yaml, lib/main.dart, lib/app.dart, lib/core/constants/, platform files)
  - _Requirements: 9, 10, 11, 29, 30_

  - [ ] 1.1 Smoke test: app boots and analyzer is clean
    - Widget test that `App` pumps without exceptions; confirm `flutter analyze` passes
    - Target: `frontend/Delivery_app/test/app_boot_test.dart`

- [ ] 2. Implement core theme tokens and Material 3 light/dark themes
  - Create `AppTokens` `ThemeExtension` with semantic color roles (primary/success/warning/error), `DeliveryStatusColor` map (assigned=blue, pickedUp=orange, delivered=green), 4-pt spacing scale, radius, elevation
  - Build `ThemeData` light and dark via `ColorScheme.fromSeed(seed, brightness)` with `useMaterial3: true`; wire both into `app.dart` with a `ThemeMode` provider hook
  - Target: `lib/core/theme/app_tokens.dart`, `lib/core/theme/app_theme.dart`, `lib/core/theme/theme_extensions.dart`, `lib/app.dart`
  - _Requirements: 25, 32_
  - _Property: P-10_

  - [ ] 2.1 Property test: body-text contrast ratio ≥ 4.5:1
    - Assert WCAG contrast ≥ 4.5:1 for all body-text token pairs in both light and dark themes
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-10`
    - Target: `frontend/Delivery_app/test/core/theme/contrast_property_test.dart`
    - _Requirements: 32_

- [ ] 3. Implement core error model and Result type
  - Define sealed `AppException`: NoConnection, Timeout, Unauthorized, Server, Client(fieldErrors), ApiEnvelope, Unknown
  - Define sealed `Failure`: NoConnection, Timeout, Server, Validation(fieldErrors), Conflict, RateLimit, InvalidCredentials, SessionExpired, LocationPermissionDenied, GpsDisabled, Unknown
  - Define `Result<T>` = `Either<Failure, T>` typedef with helpers (getOrThrow, fold, map)
  - Target: `lib/core/error/app_exception.dart`, `lib/core/error/failure.dart`, `lib/core/error/result.dart`
  - _Requirements: 27, 34_

- [ ] 4. Implement the networking layer
  - [ ] 4.1 Create the Dio provider and ordered interceptor chain
    - Build one Dio singleton with 15s timeouts; register interceptors in order: Auth → Logging → Retry → Unauthorized(401 seam) → Error
    - `AuthInterceptor`: attaches `Authorization: Bearer <token>` on non-`/auth/**` paths; skip on auth routes
    - `LoggingInterceptor`: redacts token value, password, latitude, longitude from all log output
    - `RetryInterceptor`: exponential backoff for idempotent GETs on timeout/transient 5xx only; never retries 4xx
    - `UnauthorizedInterceptor` (`QueuedInterceptor`): on 401, clear token via `TokenStore`, emit `SessionExpired` via `AuthEventSink`, pause location heartbeat via `LocationPausePort`; let `/auth/**` 401s pass through
    - `ErrorInterceptor`: maps any `DioException` → `AppException` → `Failure`
    - Define composition-root ports `TokenStore`, `AuthEventSink`, `LocationPausePort` with in-memory stubs so the chain compiles; bind real implementations in tasks 5 and 11
    - Target: `lib/core/network/dio_provider.dart`, `lib/core/network/interceptors/`
    - _Requirements: 3, 4, 27, 30, 34_

  - [ ] 4.2 Implement ApiClient with delivery-specific method signatures
    - Build typed helpers: `postJson`, `patchJson` for bare-body calls; `postVoid` for fire-and-forget (location heartbeat, online/offline, picked-up, delivered)
    - All methods accept a `CancelToken?` for screen-dispose cancellation
    - Target: `lib/core/network/api_client.dart`
    - _Requirements: 6, 7, 10, 18, 19, 34_

  - [ ] 4.3 Implement the exception-to-failure mapper
    - Map every transport outcome to exactly one `Failure`; preserve server field-error maps for 400 responses
    - Target: `lib/core/error/error_mapper.dart`
    - _Requirements: 27, 34_
    - _Property: P-6_

  - [ ] 4.4 Property test: auth header attachment
    - For any request path, `Authorization` header attached iff not under `/auth/`
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-5`
    - Target: `frontend/Delivery_app/test/core/network/auth_header_property_test.dart`
    - _Property: P-5_

  - [ ] 4.5 Property test: failure classification mapping
    - For any transport outcome, assert exactly one `Failure` produced and no field-error entry lost
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-6`
    - Target: `frontend/Delivery_app/test/core/network/failure_mapping_property_test.dart`
    - _Property: P-6_

  - [ ] 4.6 Property test: sensitive value redaction in logs
    - For any log record embedding a JWT, password, latitude, or longitude, assert the logged output never contains those values
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-6b`
    - Target: `frontend/Delivery_app/test/core/network/redaction_property_test.dart`
    - _Requirements: 30_

- [ ] 5. Implement core storage wrappers and bind the token store
  - Create `flutter_secure_storage` wrapper for the JWT (read/write/clear) and a `SharedPreferences` wrapper for non-sensitive prefs (theme mode, availability status, heartbeat config)
  - Bind the network `TokenStore` port to the secure-storage implementation; bind `AuthEventSink` to the session stream
  - Target: `lib/core/storage/secure_storage.dart`, `lib/core/storage/preferences.dart`
  - _Requirements: 3, 5, 25, 30_

  - [ ] 5.1 Unit tests for storage wrappers
    - Verify token read/write/clear and prefs read/write using fakes
    - Target: `frontend/Delivery_app/test/core/storage/storage_test.dart`

- [ ] 6. Implement input validators
  - Create pure validators: email well-formedness; password 8–25 characters; non-blank full name (reject whitespace-only); phone `^[6-9]\d{9}$`; non-blank license number; vehicle type selection
  - Expose combined submit-gate functions for register and login
  - Target: `lib/core/validation/validators.dart`
  - _Requirements: 1, 2_
  - _Property: P-4_

  - [ ] 6.1 Property test: registration and login validation gating
    - Registration submittable iff email valid AND password 8–25 AND name non-blank AND phone matches AND license non-blank; login submittable iff email valid AND password 8–25
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-4`
    - Target: `frontend/Delivery_app/test/core/validation/validation_property_test.dart`
    - _Property: P-4_

- [ ] 7. Implement DTO models, domain entities, and mappers
  - [ ] 7.1 Create freezed/json_serializable DTOs mirroring backend wire shape
    - Implement `AuthResponseDto` (token, userId, fullName, email, role), `UserResponseDto`, `LocationUpdateRequestDto` (latitude, longitude) with exact field names and validation bounds
    - Add `DecimalJsonConverter` for payout/earnings fields (reading number-or-string, writing canonical string); keep temporal fields as raw `String`; run `build_runner`
    - Target: `lib/features/authentication/data/dtos/`, `lib/features/location/data/dtos/`, `lib/core/utils/decimal_converter.dart`
    - _Requirements: 1, 2, 10, 35_

  - [ ] 7.2 Create domain entities and DTO↔entity mappers
    - Implement `PartnerSession`, `DeliveryAssignment`, `DeliveryRecord`, `EarningsSummary`, `DailyEarning`, `LatLng`, `RouteInfo`, `AppNotification`, `AppSettings`
    - Mappers parse raw temporal strings to `DateTime`; `PartnerSession` decodes JWT payload via `jwt_decoder`
    - Target: `lib/features/**/domain/entities/`, `lib/features/**/data/mappers/`
    - _Requirements: 2, 3_
    - _Property: P-1_

  - [ ] 7.3 Property test: serialization round-trip
    - For any DTO (auth response, location request, assignment, delivery record, earnings), assert `fromJson(toJson(model)) == model`
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-1`
    - Target: `frontend/Delivery_app/test/data/serialization_round_trip_property_test.dart`
    - _Property: P-1_

- [ ] 8. Implement routing, session repository, and startup guard
  - [ ] 8.1 Implement SessionRepository and PartnerSession decoding
    - Implement `SessionRepositoryImpl` (persist/clear/current/changes stream); decode JWT via `jwt_decoder` into `PartnerSession{partnerId, email, role, name, phone, exp}`; treat expired as unauthenticated
    - Bind `AuthEventSink` (task 4) so the 401 interceptor clears this session; bind `LocationPausePort` so 401 pauses heartbeats
    - Target: `lib/features/authentication/data/repositories/session_repository_impl.dart`, domain interfaces
    - _Requirements: 3, 4, 5_
    - _Property: P-4_

  - [ ] 8.2 Implement GoRouter table, redirect guard, and app-start bootstrap
    - Build the route table: `/splash`, `/login`, `/register`, and a protected `ShellRoute` for `/home`, `/assignment/:orderId`, `/navigate/:orderId/:destination`, `/history`, `/earnings`, `/profile`, `/notifications`, `/settings`
    - Implement `redirect` guard with `refreshListenable` bridged from `SessionRepository.changes()`; implement splash-screen bootstrap routing to `/home` or `/login` based on token validity
    - Handle FCM notification deep links: `DELIVERY_ASSIGNED` → `/assignment/${orderId}`, `ORDER_READY_FOR_PICKUP` → `/navigate/${orderId}/restaurant`, `SYSTEM` → `/notifications`
    - Target: `lib/core/routing/app_router.dart`, `lib/core/routing/routes.dart`, `lib/bootstrap/app_startup.dart`
    - _Requirements: 3, 13, 14, 28_

  - [ ] 8.3 Property test: startup session route decision
    - For any (token-present, token-expired) combination: route to `/home` iff present AND not expired, else `/login`
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-4b`
    - Target: `frontend/Delivery_app/test/features/authentication/startup_route_property_test.dart`

- [ ] 9. Checkpoint — core foundation
  - All tests pass; `flutter analyze` clean; app boots to splash and routes correctly; ask user if questions arise

- [ ] 10. Implement the authentication feature
  - [ ] 10.1 Implement AuthRepository and remote data source
    - Implement `AuthRemoteDataSource` and `AuthRepositoryImpl` for `POST /auth/register/delivery` and `POST /auth/login/delivery-person`; on login persist session; map 201→success, 409→Conflict, 429→RateLimit, 401→InvalidCredentials, 400→Validation
    - Target: `lib/features/authentication/data/`
    - _Requirements: 1, 2_

  - [ ] 10.2 Implement login and register screens with AuthController
    - Build `LoginScreen` and `RegisterScreen` with `AuthController` (AsyncNotifier), field-level validation messages, loading-state disabling duplicate submit, route-to-login on register success
    - Implement logout: if Online → `POST /api/delivery/partners/{id}/offline` (best-effort) → clear session → navigate to login, clearing history stack; warn when active assignment present
    - Target: `lib/features/authentication/presentation/`
    - _Requirements: 1, 2, 5_

  - [ ] 10.3 Unit and widget tests for auth flows
    - Test: 201→success+route, 409 duplicate, 429 rate-limit, 401 invalid-credentials, 400 field mapping, loading disables submit, logout clears session and stack, logout warns on active assignment
    - Target: `frontend/Delivery_app/test/features/authentication/`

- [ ] 11. Implement the availability feature
  - [ ] 11.1 Implement AvailabilityRepository and remote data source
    - Implement `AvailabilityRemoteDataSource` and `AvailabilityRepositoryImpl` for `POST /api/delivery/partners/{id}/online` and `POST /api/delivery/partners/{id}/offline`; persist last-known status to preferences
    - **Note:** Requires Gap 0 fix (gateway routing). Document the expected path in a `// TODO: Gap 0` comment.
    - Target: `lib/features/availability/data/`
    - _Requirements: 6, 7, 8_

  - [ ] 11.2 Implement AvailabilityController and home-screen toggle
    - Build `AvailabilityController` (Notifier): `goOnline()` checks permission → calls repo → starts heartbeat on success; `goOffline()` warns on active assignment → calls repo → stops heartbeat; renders Online/Offline toggle with loading/disabled states; persists status locally
    - Build the `HomeScreen` shell: availability toggle, GPS status badge, active-assignment card slot, earnings mini-summary card
    - Target: `lib/features/availability/presentation/`, `lib/features/home/`
    - _Requirements: 6, 7, 8_

  - [ ] 11.3 Widget tests for availability toggle
    - Test: cannot go online without permission, loading state prevents duplicate tap, offline request called on logout, warn displayed when active assignment present
    - Target: `frontend/Delivery_app/test/features/availability/`

- [ ] 12. Implement location core (coordinator validator, heartbeat throttle, permission handler)
  - [ ] 12.1 Implement pure location utilities
    - `CoordinateValidator.validate(lat, lng, accuracy)` — rejects out-of-bounds coordinates, accuracy > 50m, and suspected mock locations; returns `Either<LocationFailure, LatLng>`
    - `HeartbeatThrottle.shouldSubmit(current, last, batteryLevel)` — applies 15m distance filter and battery-aware interval (10s normal, 30s when battery < 15%); pure function with no I/O
    - `EarningsCalculator.summarise(records)` — aggregates `DeliveryRecord` list into `EarningsSummary`; pure function
    - Target: `lib/core/location/coordinate_validator.dart`, `lib/core/location/heartbeat_throttle.dart`, `lib/features/earnings/domain/earnings_calculator.dart`
    - _Requirements: 10, 12, 31, 35_
    - _Property: P-2, P-3_

  - [ ] 12.2 Property test: HeartbeatThrottle distance filter
    - For any pair of positions within 15m, `shouldSubmit` returns false; for any pair beyond 15m, returns true; battery < 15% sets interval to 30s
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-2`
    - Target: `frontend/Delivery_app/test/core/location/heartbeat_throttle_property_test.dart`
    - _Property: P-2_

  - [ ] 12.3 Property test: CoordinateValidator bounds
    - For any lat outside [-90,90] or lng outside [-180,180] or accuracy > 50m, validator returns Left; valid coordinates return Right
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-3`
    - Target: `frontend/Delivery_app/test/core/location/coordinate_validator_property_test.dart`
    - _Property: P-3_

  - [ ] 12.4 Implement LocationPermissionHandler
    - Request foreground permission; if granted on Android 10+, request background; store highest granted level; detect permanent denial and open app-settings; re-evaluate on each `goOnline` call
    - Target: `lib/core/location/location_permission_handler.dart`
    - _Requirements: 9_

  - [ ] 12.5 Implement LocationRepository and foreground GPS data source
    - Wrap `geolocator` position stream with `HeartbeatThrottle` and `CoordinateValidator`; submit heartbeats to `POST /api/delivery/partners/{id}/location`; cache failed fixes in memory; retry with exponential backoff (max 3)
    - Expose `positionStream`, `statusStream`, `startHeartbeat(config)`, `stopHeartbeat()`, `flushCachedFixes()`
    - Bind `LocationPausePort` from task 4 to `stopHeartbeat()`
    - Target: `lib/features/location/data/`
    - _Requirements: 10, 12_

  - [ ] 12.6 Repository test: location heartbeat submission
    - `LocationRepositoryImpl` does not call datasource when `shouldSubmit` returns false; calls datasource when moved beyond filter; retries on network error up to 3 times
    - Target: `frontend/Delivery_app/test/features/location/`

- [ ] 13. Implement Android background location (foreground service)
  - [ ] 13.1 Set up flutter_foreground_task with location entry point
    - Configure `flutter_foreground_task` with `androidNotificationOptions` (persistent notification, ongoing, location icon); implement `@pragma('vm:entry-point') void startCallback()` that initialises a minimal Dio client and runs the heartbeat loop using `geolocator`
    - Handle `FlutterForegroundTask.sendDataToMain()` for status updates back to the UI isolate
    - Target: `lib/core/location/background_location_service.dart`, `android/app/src/main/AndroidManifest.xml`
    - _Requirements: 11_

  - [ ] 13.2 Integrate background service with AvailabilityController
    - `goOnline()` → start foreground service when app enters background; `goOffline()` → stop foreground service; `AppLifecycleObserver` triggers service start/stop on foreground/background transitions
    - Battery-awareness: monitor battery level stream; send `changeBatteryMode(level)` message to background isolate
    - Target: `lib/features/availability/`, `lib/core/location/background_location_service.dart`
    - _Requirements: 11, 29, 31_

- [ ] 14. Implement iOS background location
  - Configure significant-location-change monitoring in `AppDelegate.swift`; add `background_fetch` handler that flushes cached fixes; set `allowsBackgroundLocationUpdates = true` when an Active_Assignment is present
  - Validate all required `Info.plist` keys and `UIBackgroundModes` entries are present
  - Target: `ios/Runner/AppDelegate.swift`, `ios/Runner/Info.plist`
  - _Requirements: 11_

- [ ] 15. Implement push notification infrastructure
  - [ ] 15.1 Set up Firebase Messaging and local notifications
    - Initialise `firebase_messaging` in `main.dart`; register top-level `firebaseMessagingBackgroundHandler`; request notification permission via `requestPermission()`; obtain and store FCM token (for future backend registration — see Gap 6)
    - Configure `flutter_local_notifications` with Android channel (high importance, `delivery_alerts`) and iOS categories; implement foreground notification display via `onMessage` handler
    - Target: `lib/core/notifications/fcm_service.dart`, `lib/core/notifications/local_notification_service.dart`, `lib/main.dart`
    - _Requirements: 13, 14, 28_

  - [ ] 15.2 Implement NotificationRepository (local store) and deep-link handler
    - Implement `NotificationRepositoryImpl` using `SharedPreferences` (JSON-encoded list of `AppNotification`); handle foreground/background/terminated tap events; route by `type` field in FCM data payload; expose `unreadCount` stream
    - Build `NotificationRouter` that maps FCM payload `{type, orderId}` to GoRouter path: DELIVERY_ASSIGNED → `/assignment/$orderId`, ORDER_READY_FOR_PICKUP → `/navigate/$orderId/restaurant`, SYSTEM → `/notifications`
    - Target: `lib/features/notifications/data/`, `lib/core/notifications/notification_router.dart`
    - _Requirements: 13, 14, 24, 28_

  - [ ] 15.3 Widget test: notification deep link routing
    - DELIVERY_ASSIGNED routes to AssignmentDetailScreen; ORDER_READY_FOR_PICKUP routes to NavigationScreen restaurant destination; unknown type routes to Notifications
    - Target: `frontend/Delivery_app/test/features/notifications/`

- [ ] 16. Implement offline confirmation queue
  - Implement `OfflineQueueImpl` backed by `SharedPreferences`; enqueue `PendingConfirmation{id, orderId, type, enqueuedAt, retryCount}`; drain on connectivity restoration via `connectivity_plus` stream; remove on success; increment `retryCount` on failure; surface a persistent error after 3 retries
  - Integrate queue with `AssignmentRepository.markPickedUp` and `markDelivered`: if `NoConnectionFailure`, enqueue and return a `QueuedResult`
  - Bind `connectivity_plus` `connectivityStream` to a `ConnectivityRepository`; on reconnect drain offline queue
  - Target: `lib/core/offline_queue/`, `lib/features/assignment/data/repositories/`
  - _Requirements: 26_
  - _Property: P-9_

  - [ ] 16.1 Property test: offline queue FIFO ordering
    - For any sequence of enqueued confirmations, drain returns them in FIFO order
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-9`
    - Target: `frontend/Delivery_app/test/core/offline_queue/queue_property_test.dart`
    - _Property: P-9_

- [ ] 17. Implement the assignment feature (view, pickup, delivery)
  - [ ] 17.1 Implement AssignmentRepository and use cases
    - Implement `AssignmentRepositoryImpl`: `cacheAssignment(assignment)` persists to `SharedPreferences`; `getActiveAssignment()` returns cached assignment (backend GET endpoint is Gap 3); `markPickedUp(orderId)` calls `POST /api/delivery/assignments/{orderId}/picked-up`; `markDelivered(orderId)` calls `POST /api/delivery/assignments/{orderId}/delivered`; both delegate to offline queue on `NoConnectionFailure`
    - Implement `ConfirmPickupUseCase` and `ConfirmDeliveryUseCase` validating current status before each call
    - **Note:** Requires Gap 0 fix. Document with `// TODO: Gap 0` comment.
    - Target: `lib/features/assignment/data/`, `lib/features/assignment/domain/usecases/`
    - _Requirements: 15, 18, 19_

  - [ ] 17.2 Implement AssignmentController and assignment detail screen
    - Build `AssignmentController` (AsyncNotifier): loads from cache; exposes `confirmPickup()` and `confirmDelivery()` methods with loading-state guards; updates `DeliveryStatus` on success; clears assignment on `DELIVERED`
    - Build `AssignmentDetailScreen`: renders assignment details (restaurant name/address, customer name/address, item count, status); shows "Navigate to Restaurant" primary CTA in ASSIGNED state, "Confirm Pickup" button when at restaurant, "Navigate to Customer" after pickup, "Confirm Delivery" when at customer; status progress indicator bar across all states; queued-confirmation badge when offline
    - Wire FCM `onMessage` / `onBackgroundMessage` to `AssignmentController.cacheAssignment` when type is `DELIVERY_ASSIGNED`
    - Target: `lib/features/assignment/presentation/`
    - _Requirements: 15, 16, 18, 19_

  - [ ] 17.3 Property test: assignment state machine transitions
    - No transition from `delivered` to any other state; `assigned → pickedUp → delivered` is the only valid forward path; no state transition occurs if the confirmation HTTP call returns an error
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-8`
    - Target: `frontend/Delivery_app/test/features/assignment/state_machine_property_test.dart`
    - _Property: P-8_

  - [ ] 17.4 Repository tests for assignment lifecycle
    - `markPickedUp` returns `Either.right` on 200; `Either.left(ServerFailure)` on 5xx; enqueues `PendingConfirmation` on `NoConnectionFailure`; 409 treated as success (idempotent)
    - Target: `frontend/Delivery_app/test/features/assignment/`

- [ ] 18. Implement the navigation/maps feature
  - [ ] 18.1 Implement NavigationRepository (route and external launch)
    - Implement `NavigationRepositoryImpl`: `getRoute(origin, destination)` calls Google Directions API if API key configured, else falls back to straight-line `RouteInfo` using Haversine; `launchExternalNav(destination, label)` builds platform URI and calls `url_launcher`; falls back to browser URL if Google Maps not installed
    - Target: `lib/features/navigation/data/`
    - _Requirements: 17_

  - [ ] 18.2 Implement NavigationController and NavigationScreen
    - Build `NavigationController` (AsyncNotifier): subscribes to `LocationRepository.positionStream`; calls `getRoute` when position changes > 30m; exposes `currentPosition`, `destination`, `routeInfo`, `destinationLabel`; auto-switches destination from restaurant to customer when assignment advances to `PICKED_UP`
    - Build `NavigationScreen` with `GoogleMap` widget: partner position marker (blue), destination marker (color per destination type), polyline, distance chip, ETA chip, "Launch in Google Maps" FAB; offline banner when disconnected; `CameraPosition` tracks partner position
    - Target: `lib/features/navigation/presentation/`
    - _Requirements: 17_

  - [ ] 18.3 Widget test: NavigationScreen destination switching
    - Verify destination marker switches from restaurant to customer when assignment status changes to `pickedUp`; verify offline banner appears when `locationStatus` is `unavailable`
    - Target: `frontend/Delivery_app/test/features/navigation/`

- [ ] 19. Implement delivery history feature
  - Implement `HistoryLocalDataSource` backed by `sqflite` (table: delivery_records with orderId, deliveredAt, pickupAddress, dropAddress, distanceKm, payout); insert record after every successful `markDelivered` call; paginated query (page size 20, descending by deliveredAt)
  - Implement `HistoryRepositoryImpl` with `getHistory(page)` returning `PageResult<DeliveryRecord>`; expose the local-backed interface so a future backend endpoint replaces storage without screen changes (`// TODO: Gap 4`)
  - Build `DeliveryHistoryScreen` with infinite-scroll `ListView.builder`, shimmer placeholder, empty state, per-row card showing date/route/payout
  - Target: `lib/features/history/`
  - _Requirements: 20_

- [ ] 20. Implement earnings feature
  - [ ] 20.1 Implement EarningsCalculator (pure)
    - `EarningsCalculator.summarise(List<DeliveryRecord>)` — sums payout for today, current week (Mon-Sun), all-time; produces `EarningsSummary` with `weekBreakdown: List<DailyEarning>`; pure with no I/O
    - Target: `lib/features/earnings/domain/earnings_calculator.dart`
    - _Requirements: 21, 22_
    - _Property: P-7_

  - [ ] 20.2 Property test: EarningsCalculator correctness
    - For any set of DeliveryRecords, `todayTotal + futureDeliveries total == allTimeTotal` does not hold but within-range sums are exact (no floating point); today total equals sum of records with `deliveredAt` on today's date
    - `fast_check`, ≥100 iterations; tag `// Feature: delivery-app, Property P-7`
    - Target: `frontend/Delivery_app/test/features/earnings/earnings_calculator_property_test.dart`
    - _Property: P-7_

  - [ ] 20.3 Implement EarningsRepository and EarningsScreen
    - `EarningsRepositoryImpl`: reads `DeliveryRecord` list from `HistoryLocalDataSource`; passes to `EarningsCalculator`; expose interface for future backend endpoint (`// TODO: Gap 5`)
    - Build `EarningsScreen`: today card (total + delivery count), weekly bar chart (7-bar, intl-formatted amounts), all-time stats; real-time update when new delivery completed
    - Target: `lib/features/earnings/`
    - _Requirements: 21, 22_

- [ ] 21. Implement profile feature
  - `ProfileRepositoryImpl`: reads `PartnerSession` from `SessionRepository`; reads vehicleType/licenseNumber from `SharedPreferences`; expose interface for future `GET /auth/delivery-person/me` endpoint (`// TODO: Gap 2`)
  - Build `ProfileScreen`: full name, email, phone, role from session; vehicle type, license from local storage; all editing controls disabled with "coming soon" state
  - Target: `lib/features/profile/`
  - _Requirements: 23_

- [ ] 22. Implement notification center feature
  - Build `NotificationCenterScreen`: `ListView.builder` of stored `AppNotification` entries in reverse chronological order; unread badge; tap → deep-link router; "Mark all read" action; empty state
  - `NotificationsController` observes `NotificationRepository.unreadCount` stream to keep the badge on the bottom nav in sync
  - Target: `lib/features/notifications/presentation/`
  - _Requirements: 24_

- [ ] 23. Implement settings feature
  - Build `SettingsScreen`: light/dark/system theme picker (persisted via preferences); assignment notification sound toggle; background location permission status indicator with shortcut to device settings; app version display
  - `SettingsController` (Notifier) reads/writes preferences; emitting to `settingsProvider` triggers theme change in `app.dart` without restart
  - Target: `lib/features/settings/`
  - _Requirements: 25_

- [ ] 24. Implement app lifecycle handling
  - Register `AppLifecycleObserver` (WidgetsBindingObserver) in the root widget; on `resumed`: reconcile availability status, resume foreground GPS, flush offline queue; on `paused`: transition Android to background foreground service; on `detached`: best-effort offline call + location flush
  - Restore `activeAssignmentProvider` from cache on cold start when partner was Online with an Active_Assignment
  - Target: `lib/bootstrap/app_lifecycle_observer.dart`, `lib/main.dart`
  - _Requirements: 29_

- [ ] 25. Implement shared widget catalog and UI polish
  - [ ] 25.1 Build shared widgets
    - `LoadingOverlay` (full-screen spinner), `ErrorState` (icon + message + retry button), `EmptyState` (icon + message), `ShimmerList` (parameterised skeleton cards), `StatusBadge` (colored chip per DeliveryStatus), `OfflineBanner` (persistent top bar), `GPSWarningBanner`, `QueuedBadge`
    - Target: `lib/core/widgets/`
    - _Requirements: 26, 27, 32_

  - [ ] 25.2 Apply accessibility labels and contrast
    - Audit every interactive control: add `Semantics` wrappers with labels; ensure 48×48 touch targets; verify text scaling responds to OS setting; announce assignment arrival via `SemanticsService.announce`
    - Target: all `presentation/screens/`
    - _Requirements: 32_

  - [ ] 25.3 Apply responsive layout breakpoints
    - Verify 360dp–480dp single-column layout; add 600dp+ expanded panel layout for HomeScreen and EarningsScreen
    - Target: all `presentation/screens/`
    - _Requirements: 33_

  - [ ] 25.4 Micro-interactions and animations
    - Online/Offline toggle pulse animation (Lottie); assignment arrival hero animation card; status progress bar animated step transitions; delivery complete confetti/shimmer finish; pull-to-refresh on history and earnings screens
    - Target: `lib/features/*/presentation/screens/`
    - _Requirements: 15, 16, 18, 19_

- [ ] 26. End-to-end integration test
  - Build an integration test using `flutter_test` + `http_mock_adapter` that runs the full golden path:
    1. Launch app → login (`POST /auth/login/delivery-person` mock → 200)
    2. Go Online (`POST /api/delivery/partners/{id}/online` mock → 200)
    3. Simulate GPS position update (mock geolocator stream) → heartbeat submitted
    4. Simulate FCM `DELIVERY_ASSIGNED` push → assignment card appears on home screen
    5. Navigate to Assignment screen → Navigate to Restaurant screen
    6. Confirm Pickup (`POST /api/delivery/assignments/{orderId}/picked-up` mock → 200) → status advances to `PICKED_UP`
    7. Navigate to Customer screen → Confirm Delivery (`POST /api/delivery/assignments/{orderId}/delivered` mock → 200) → delivery complete card shown
    8. Go Offline (`POST /api/delivery/partners/{id}/offline` mock → 200) → status shows Offline
  - Target: `frontend/Delivery_app/integration_test/full_delivery_flow_test.dart`
  - _Requirements: 1–35_

- [ ] 27. Final checkpoint
  - All unit, widget, property, and integration tests pass; `flutter analyze` clean; no sensitive values in logs; app boots correctly from cold start in both Online and Offline last-state scenarios; ask user if questions arise
