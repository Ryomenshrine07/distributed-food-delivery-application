# Requirements Document — Delivery Partner App

## Introduction

This document specifies the requirements for the **Delivery Partner App**, the delivery-partner-facing mobile application of the existing Food Delivery Platform. The Delivery Partner App is one of three frontend clients alongside the Customer App and the Admin Dashboard.

The application is built with Flutter and Material 3, using Riverpod for state management, Dio for networking, GoRouter for routing, Flutter Secure Storage for token persistence, Google Maps Flutter for navigation, and `geolocator` together with `permission_handler` for location services. The codebase follows Clean Architecture with a feature-first folder structure and targets the directory `frontend/Delivery_app`.

The platform backend already exists as a set of Spring Boot microservices behind a Spring Cloud Gateway. The gateway enforces JWT authentication on all routes except `/auth/**` and injects identity headers (`X-User-Id`, `X-User-Email`, `X-User-Role`, `X-User-Name`, `X-User-Phone`) into downstream requests. The delivery service exposes partner-management and assignment-lifecycle endpoints. Authentication tokens for delivery partners carry the `DELIVERY_PERSON` role.

**Critical infrastructure gap:** The API Gateway routes `/deliveries/**` and `/delivery-partners/**` but the Delivery Service controllers are mapped to `/api/delivery/assignments/**` and `/api/delivery/partners/**`. This routing mismatch (Gap 0) must be resolved before the Delivery App can reach the delivery service through the gateway.

Every requirement maps to an existing REST endpoint where one exists. Where a capability cannot be served by an existing endpoint the requirement references a documented entry in the **Backend Gaps & Resolution Strategy** section.

This is a requirements document only. It does not contain design or implementation detail.

---

## Glossary

### System Components

- **Delivery_App**: The complete Flutter delivery-partner application described by this document.
- **Auth_Module**: Registration, login, logout, and credential management for delivery partners.
- **Session_Manager**: Stores, retrieves, attaches, and clears the JWT and the derived `PartnerSession` (partnerId, email, role, name, phone, exp).
- **Network_Layer**: Dio-based component responsible for HTTP requests, JWT attachment, timeout/cancellation, and error surfacing.
- **Availability_Module**: Manages the partner's online/offline status and the toggle control on the home screen.
- **Location_Module**: Manages location permissions, foreground GPS updates, background GPS updates, heartbeat scheduling, batching, offline caching, and submission to the delivery service.
- **Assignment_Module**: Receives incoming delivery assignments via push notification, displays assignment details, and drives the pickup → delivery lifecycle.
- **Navigation_Module**: Renders a live map with the partner's position, destination marker, polyline route, distance, and ETA; supports launching external navigation apps.
- **History_Module**: Displays the partner's past completed deliveries.
- **Earnings_Module**: Displays today's earnings, weekly earnings, and an earnings breakdown.
- **Profile_Module**: Displays the partner's identity information and account status.
- **Notification_Module**: Receives push notifications, maintains a local notification list, and routes to relevant screens on tap.
- **Settings_Module**: Manages theme mode, notification preferences, and other client preferences.

### Domain Terms

- **API_Gateway**: The Spring Cloud Gateway exposing the backend at a single base URL and enforcing JWT authentication.
- **JWT**: The single bearer token returned by the auth service on successful login, carrying partnerId, email, role, name, phone, and expiry.
- **PartnerSession**: The decoded JWT payload used throughout the app — fields: `partnerId` (UUID), `email`, `role` (DELIVERY_PERSON), `name`, `phone`, `exp`.
- **PartnerId**: The UUID of the `DeliveryPerson` entity in the auth service, returned as `userId` in `AuthResponse` and injected as `X-User-Id` by the gateway. Used as the path variable in partner endpoints.
- **DeliveryAssignment**: A backend record linking an orderId, restaurantId, customerId, and partnerId with a `DeliveryStatus` lifecycle.
- **DeliveryStatus**: One of `ASSIGNED`, `PICKED_UP`, `DELIVERED`.
- **Active_Assignment**: An assignment whose status is `ASSIGNED` or `PICKED_UP`.
- **Redis_GEO**: The Redis geospatial index that the delivery service uses to find the nearest available partner during assignment. The app feeds it via the GPS heartbeat endpoint.
- **GPS_Heartbeat**: A periodic `POST /api/delivery/partners/{id}/location` call that pushes the partner's current coordinates to the delivery service, which writes them to Redis GEO.
- **Online**: The partner state in which they are eligible for delivery assignments and actively pushing GPS heartbeats.
- **Offline**: The partner state in which they are not eligible for assignment and are not required to push GPS.
- **Backend_Gap**: A required partner capability with no existing backend endpoint, tracked in the Backend Gaps section.
- **LocationUpdateRequest**: The backend DTO expected at the GPS heartbeat endpoint — fields: `latitude` (double, -90 to 90), `longitude` (double, -180 to 180).
- **AuthResponse**: The backend DTO returned on successful login — fields: `token`, `userId` (UUID), `fullName`, `email`, `role`.
- **UserResponse**: The backend DTO returned on successful registration — fields: `id`, `fullName`, `email`, `phone`, `role`.

### Backend Endpoint Reference (verified)

- `POST /auth/register/delivery` — register a delivery partner; request: `{email, password, fullName, phone, vehicleType, licenseNumber}`; response: `UserResponse`; rate limited 3/hour/IP.
- `POST /auth/login/delivery-person` — authenticate a delivery partner; request: `{email, password}`; response: `AuthResponse{token, userId, fullName, email, role}`; rate limited 5/min/IP.
- `POST /api/delivery/partners/{id}/location` — GPS heartbeat; body: `{latitude, longitude}`; response: 202 Accepted. **[Requires Gap 0 fix]**
- `POST /api/delivery/partners/{id}/online` — mark partner as online and eligible for assignments. **[Requires Gap 0 fix]**
- `POST /api/delivery/partners/{id}/offline` — mark partner as offline and unavailable. **[Requires Gap 0 fix]**
- `POST /api/delivery/assignments/{orderId}/picked-up` — advance assignment status to `PICKED_UP`, emit `OrderPickedUpEvent` via outbox. **[Requires Gap 0 fix]**
- `POST /api/delivery/assignments/{orderId}/delivered` — advance assignment status to `DELIVERED`, emit `OrderDeliveredEvent`, mark partner available. **[Requires Gap 0 fix]**

---

## Requirements

### Requirement 1: Delivery Partner Registration

**User Story:** As a prospective delivery partner, I want to create an account with my email, password, full name, phone number, vehicle type, and license number, so that I can start accepting deliveries.

#### Acceptance Criteria

1. WHEN a guest submits the registration form with a valid email, a password of 8 to 25 characters, a non-empty full name, an Indian phone number matching `^[6-9]\d{9}$`, a selected vehicle type, and a non-empty license number, THE Auth_Module SHALL send a registration request to `POST /auth/register/delivery`.
2. WHEN the registration request returns HTTP 201, THE Auth_Module SHALL display a registration-success confirmation and route the partner to the login screen.
3. IF any registration field fails client-side validation, THEN THE Auth_Module SHALL display a field-level validation message and SHALL withhold the registration request until all fields are valid.
4. IF the registration request returns HTTP 409 or a duplicate-account error, THEN THE Auth_Module SHALL display a message stating the email or phone is already registered.
5. IF the registration request returns HTTP 429, THEN THE Auth_Module SHALL display a message stating the registration limit is reached and advise the partner to retry later.
6. IF the registration request returns HTTP 400 with field errors, THEN THE Auth_Module SHALL display the server-provided validation messages mapped to the corresponding fields.
7. WHILE the registration request is in progress, THE Auth_Module SHALL display a loading indicator and SHALL block duplicate submissions.

**Backend mapping:** `POST /auth/register/delivery` (rate limit 3/hour/IP → 429).

> **Note:** The `RegisterDeliveryPersonRequest` DTO in the auth service contains `email`, `password`, `fullName`, `phone`. `vehicleType` and `licenseNumber` fields are client-collected but may not be persisted if the server DTO does not include them — see Gap 2.

### Requirement 2: Delivery Partner Login

**User Story:** As a registered delivery partner, I want to log in with my email and password, so that I can access my account and begin accepting deliveries.

#### Acceptance Criteria

1. WHEN a partner submits the login form with a valid email and a password of 8 to 25 characters, THE Auth_Module SHALL send an authentication request to `POST /auth/login/delivery-person`.
2. WHEN the authentication request returns HTTP 200, THE Session_Manager SHALL persist the returned JWT in secure storage, SHALL extract the `userId` as `partnerId`, and SHALL route the partner to the home screen.
3. IF the authentication request returns HTTP 401, THEN THE Auth_Module SHALL display a message stating the email or password is incorrect.
4. IF the authentication request returns HTTP 429, THEN THE Auth_Module SHALL display a message stating the login attempt limit is reached and advise the partner to retry after one minute.
5. WHILE the authentication request is in progress, THE Auth_Module SHALL display a loading indicator and SHALL block duplicate submissions.
6. WHEN the authentication request returns HTTP 200, THE Session_Manager SHALL decode the JWT and persist the `PartnerSession` (partnerId, email, role, name, phone, exp) for use by all other modules.

**Backend mapping:** `POST /auth/login/delivery-person` (request: `{email, password}`; response: `AuthResponse{token, userId, fullName, email, role}`; rate limit 5/min/IP → 429).

### Requirement 3: Session Persistence and Token Attachment

**User Story:** As a returning delivery partner, I want the app to remember my logged-in session across restarts, so that I do not need to sign in every time.

#### Acceptance Criteria

1. WHEN the Delivery_App starts AND a stored JWT is present and not expired, THE Session_Manager SHALL load the `PartnerSession` and route the partner to the home screen without requiring re-entry of credentials.
2. WHEN the Delivery_App starts AND no valid stored JWT is present, THE Session_Manager SHALL route the partner to the login screen.
3. WHEN the Network_Layer issues a request to any path other than `/auth/**`, THE Network_Layer SHALL attach the stored JWT as an `Authorization: Bearer <token>` header.
4. THE Session_Manager SHALL expose the `PartnerSession` (including `partnerId`) for use by the Availability_Module, Location_Module, and Assignment_Module as the path variable in delivery service endpoints.
5. WHERE a stored JWT is expired based on its embedded `exp` claim, THE Session_Manager SHALL treat the session as unauthenticated on app start and SHALL route the partner to the login screen.

**Backend mapping:** API_Gateway global JWT filter (all non-`/auth/**` routes require `Authorization: Bearer <token>`). Token refresh is a Backend_Gap — see Gap 1.

### Requirement 4: Session Expiry and Unauthorized Response Handling

**User Story:** As a delivery partner whose session has expired mid-shift, I want the app to handle the expiry gracefully so that I can re-authenticate without losing my shift context.

#### Acceptance Criteria

1. IF any authenticated request returns HTTP 401, THEN THE Session_Manager SHALL clear the stored JWT and SHALL route the partner to the login screen.
2. WHEN the Session_Manager clears a session due to HTTP 401, THE Auth_Module SHALL display a message stating the session has ended and the partner must sign in again.
3. THE Network_Layer SHALL expose a single interception point for HTTP 401 handling so that a future token-refresh flow can be introduced without restructuring request code.
4. IF an HTTP 401 is received while the partner is Online and pushing GPS heartbeats, THE Location_Module SHALL pause heartbeat submissions until the partner re-authenticates.

**Backend mapping:** BACKEND GAP — see Gap 1 (no refresh endpoint; current behavior: clear session → login).

### Requirement 5: Logout

**User Story:** As a logged-in delivery partner, I want to log out, so that my account is protected when I hand the device to someone else.

#### Acceptance Criteria

1. WHEN a partner confirms logout, THE Session_Manager SHALL delete the stored JWT and all cached `PartnerSession` data from device storage.
2. IF the partner is Online at the time of logout, THE Availability_Module SHALL send `POST /api/delivery/partners/{id}/offline` before clearing the session.
3. WHEN logout completes, THE Auth_Module SHALL route the partner to the login screen and SHALL remove all authenticated screens from the navigation history.
4. WHEN the partner is in the middle of an Active_Assignment and attempts logout, THE Auth_Module SHALL warn that an active delivery is in progress and SHALL require a second confirmation before proceeding.

**Backend mapping:** `POST /api/delivery/partners/{id}/offline` (step 2, best-effort); no server-side token revocation — see Gap 1.

### Requirement 6: Go Online

**User Story:** As a delivery partner ready to accept orders, I want to toggle my status to Online, so that the system can assign deliveries to me.

#### Acceptance Criteria

1. WHEN a partner taps the Go Online control on the home screen, THE Availability_Module SHALL first verify that location permission (at least "while in use") has been granted before proceeding.
2. IF location permission is not granted, THEN THE Availability_Module SHALL trigger the Permission_Flow (Requirement 10) and SHALL proceed with going online only after permission is granted.
3. WHEN location permission is confirmed, THE Availability_Module SHALL send `POST /api/delivery/partners/{partnerId}/online` and SHALL start the GPS_Heartbeat on success.
4. WHEN the online request returns HTTP 200, THE Availability_Module SHALL update the displayed status to Online and SHALL activate the GPS_Heartbeat.
5. IF the online request fails due to a network error, THEN THE Availability_Module SHALL display an error message and SHALL NOT change the displayed status.
6. WHILE the online request is in progress, THE Availability_Module SHALL display a loading state on the toggle control and SHALL prevent duplicate requests.

**Backend mapping:** `POST /api/delivery/partners/{id}/online` (Requires Gap 0 fix; 200 OK on success).

### Requirement 7: Go Offline

**User Story:** As a delivery partner finishing my shift, I want to toggle my status to Offline, so that no new assignments are made to me.

#### Acceptance Criteria

1. WHEN a partner taps the Go Offline control, THE Availability_Module SHALL send `POST /api/delivery/partners/{partnerId}/offline` and SHALL stop the GPS_Heartbeat on success.
2. WHEN the offline request returns HTTP 200, THE Availability_Module SHALL update the displayed status to Offline and SHALL stop GPS_Heartbeat submissions.
3. IF the partner has an Active_Assignment when attempting to go offline, THEN THE Availability_Module SHALL warn the partner and SHALL require confirmation before sending the offline request.
4. IF the offline request fails due to a network error, THE Availability_Module SHALL display an error message and SHALL retain the current displayed status.
5. WHEN the Delivery_App is terminated by the OS while the partner is Online, THE Location_Module SHALL attempt a best-effort offline call through the background isolate before the process is killed.

**Backend mapping:** `POST /api/delivery/partners/{id}/offline` (Requires Gap 0 fix; 200 OK on success).

### Requirement 8: Availability Status Display

**User Story:** As a delivery partner, I want to see my current Online/Offline status prominently on the home screen, so that I always know whether I am accepting assignments.

#### Acceptance Criteria

1. THE Availability_Module SHALL display the Online/Offline status as a clearly labeled toggle on the home screen, differentiating the two states with distinct colors.
2. THE Availability_Module SHALL persist the last-known availability status locally so that the home screen renders the correct state before the first network call completes.
3. WHEN the Delivery_App returns to the foreground from a background state, THE Availability_Module SHALL reconcile the displayed status with the locally persisted status.

**Backend mapping:** Status is written to PostgreSQL via the online/offline endpoints; the display reflects the local state with no dedicated GET endpoint — see Gap 3.

### Requirement 9: Location Permission Request Flow

**User Story:** As a delivery partner, I want the app to guide me through location permission setup, so that live GPS tracking works correctly.

#### Acceptance Criteria

1. WHEN the Delivery_App first requires location access, THE Location_Module SHALL request foreground ("when in use") permission using `permission_handler` with a rationale explaining why location is needed.
2. IF foreground permission is granted AND the partner is on Android 10+, THE Location_Module SHALL subsequently request background ("always") permission with a separate rationale explaining why background access is needed for GPS heartbeats during active deliveries.
3. IF the partner permanently denies foreground permission, THE Location_Module SHALL display a permission-denied screen explaining the impact on delivery eligibility and SHALL offer a link to the device app-settings page.
4. IF the partner denies background permission on Android, THE Location_Module SHALL display a warning that background GPS may be interrupted and SHALL allow the partner to continue with foreground-only mode.
5. THE Location_Module SHALL store the highest granted permission level and SHALL re-evaluate permissions each time the partner attempts to Go Online.
6. IF the partner returns from device settings with permissions upgraded, THE Location_Module SHALL re-check the permission state and SHALL automatically proceed with the action that triggered the permission flow.

**Backend mapping:** No backend call (device permission handling). Permission gates access to `POST /api/delivery/partners/{id}/location`.

### Requirement 10: Foreground GPS Heartbeat

**User Story:** As an online delivery partner with the app in the foreground, I want the app to continuously send my GPS coordinates, so that the system can route the nearest available assignments to me.

#### Acceptance Criteria

1. WHEN the partner is Online AND the Delivery_App is in the foreground, THE Location_Module SHALL publish GPS coordinates to `POST /api/delivery/partners/{partnerId}/location` at a configurable heartbeat interval (default 10 seconds).
2. THE Location_Module SHALL apply a distance filter so that heartbeat submissions are skipped when the partner has not moved more than 15 meters since the last successful submission.
3. THE Location_Module SHALL use high-accuracy mode (GPS + network fused provider) when the partner is Online with an Active_Assignment and balanced-power mode when Online with no assignment.
4. WHEN the GPS provider returns a location fix with accuracy worse than 50 meters, THE Location_Module SHALL discard the fix and SHALL wait for the next interval.
5. WHEN a heartbeat submission fails due to a network error, THE Location_Module SHALL cache the coordinates locally and SHALL retry with exponential backoff up to three times before discarding the cached fix.
6. THE Location_Module SHALL record the timestamp of the last successful heartbeat for display in the home screen status area.

**Backend mapping:** `POST /api/delivery/partners/{id}/location` body: `{latitude, longitude}` (validated: lat -90 to 90, lng -180 to 180); response: 202 Accepted. Requires Gap 0 fix.

### Requirement 11: Background GPS Heartbeat

**User Story:** As an online delivery partner who switches to another app or locks the screen, I want GPS heartbeats to continue in the background, so that the system always knows my position.

#### Acceptance Criteria

1. WHEN the partner is Online AND the Delivery_App enters the background on Android, THE Location_Module SHALL maintain a foreground service (with a persistent notification) to continue GPS heartbeat submissions.
2. WHEN the partner is Online AND the Delivery_App enters the background on iOS, THE Location_Module SHALL use significant-location-change monitoring and SHALL attempt background URLSession submissions within iOS background-execution limits.
3. WHEN the background GPS service is active on Android, THE Location_Module SHALL display a persistent notification indicating the partner is online and sharing their location.
4. IF the OS terminates the background service on Android due to battery optimization, THE Location_Module SHALL re-register the foreground service when the app returns to the foreground.
5. WHEN the Delivery_App is killed by the OS (swipe-to-dismiss on Android), THE Location_Module SHALL make a best-effort attempt to flush the most recent cached location fix before the process terminates.
6. THE Location_Module SHALL implement battery-awareness: on Android, if battery level drops below 15%, THE Location_Module SHALL increase the heartbeat interval to 30 seconds and SHALL switch to balanced-power mode.

**Backend mapping:** `POST /api/delivery/partners/{id}/location` (same endpoint; background service calls it outside the Dart UI isolate).

### Requirement 12: GPS Unavailability and Location Spoofing

**User Story:** As a delivery partner in a GPS-denied environment, I want the app to handle location unavailability gracefully rather than crashing.

#### Acceptance Criteria

1. IF the device GPS provider reports no fix for more than 60 seconds while the partner is Online, THE Location_Module SHALL display a "GPS signal lost" warning on the home screen.
2. IF the device GPS is disabled (airplane mode, hardware off), THE Location_Module SHALL display a prompt to enable device location settings and SHALL provide a direct link to the device location-settings page.
3. THE Location_Module SHALL expose a `locationStatus` stream (`acquiring`, `available`, `gpsDenied`, `gpsDisabled`, `unavailable`) for screens to observe and react to.
4. WHERE mock-location detection is available on the platform, THE Location_Module SHALL flag suspected mock locations and SHALL refuse to submit them, noting the rejection in the app log.

**Backend mapping:** No backend call for unavailability handling; location is submitted only when valid.

### Requirement 13: Receive Assignment Push Notification

**User Story:** As an online delivery partner, I want to receive a push notification when a new delivery is assigned to me, so that I am immediately alerted even if the app is in the background.

#### Acceptance Criteria

1. WHEN the backend publishes a `delivery-assigned` Kafka event for the partner's `partnerId`, THE Notification_Module SHALL receive the corresponding FCM push notification in the foreground, background, and killed-app states.
2. WHEN a delivery-assignment notification arrives, THE Notification_Module SHALL display a high-priority local notification with the order identifier and a prompt to view the assignment.
3. WHEN the partner taps the delivery-assignment notification, THE Delivery_App SHALL deep-link directly to the Assignment detail screen (Requirement 15).
4. WHEN the delivery-assignment notification arrives while the app is in the foreground, THE Notification_Module SHALL display an in-app banner and SHALL navigate to the Assignment detail screen after a short delay or on partner tap.
5. THE Notification_Module SHALL not require the app to be online to deliver the notification — FCM handles transport and delivery guarantees when the device regains connectivity.

**Backend mapping:** Kafka topic `delivery-assigned` → FCM push (via Notification service; Notification service is currently a stub — see Gap 6). Deep link: Assignment screen for the received orderId.

### Requirement 14: Receive Order-Ready-for-Pickup Notification

**User Story:** As a delivery partner who has been assigned an order, I want to receive a push notification when the restaurant marks the order ready for pickup, so that I know when to arrive.

#### Acceptance Criteria

1. WHEN the restaurant publishes an `OrderReadyForPickupEvent`, THE Notification_Module SHALL receive the corresponding FCM push notification.
2. WHEN the ready-for-pickup notification arrives, THE Notification_Module SHALL display a high-priority notification prompting the partner to proceed to the restaurant.
3. WHEN the partner taps the ready-for-pickup notification, THE Delivery_App SHALL deep-link to the Navigation screen for the restaurant destination (Requirement 17).

**Backend mapping:** Kafka topic `order-ready-for-pickup` published by restaurant service → FCM (Notification service stub — see Gap 6).

### Requirement 15: View Current Active Assignment

**User Story:** As a delivery partner with an active assignment, I want to see all relevant details of the delivery on my home screen, so that I know where to go and what I am carrying.

#### Acceptance Criteria

1. WHEN the Delivery_App launches and the partner is Online with an Active_Assignment, THE Assignment_Module SHALL display the current assignment prominently on the home screen.
2. THE Assignment_Module SHALL display the following assignment details: orderId reference, restaurant name, restaurant address, estimated pickup distance, customer name (first name only), delivery address, estimated delivery distance, and a summary item count.
3. THE Assignment_Module SHALL persist the assignment details locally upon receipt so that the assignment screen is available offline without a network call.
4. WHEN the assignment details are unavailable (partner just came online, app restart), THE Assignment_Module SHALL attempt to fetch the current assignment from the backend assignment detail endpoint.
5. THE Assignment_Module SHALL track assignment expiry: if an assignment goes unacknowledged for more than a configurable window, THE Assignment_Module SHALL display an "assignment may have expired" warning.

**Backend mapping:** BACKEND GAP — see Gap 3 (no GET endpoint for current active assignment; no assignment detail endpoint with restaurant/customer addresses — see Gap 7).

### Requirement 16: Assignment Lifecycle — Assigned State

**User Story:** As a delivery partner with a new assignment, I want to see a clear call-to-action to navigate to the restaurant, so that I can begin the pickup.

#### Acceptance Criteria

1. WHEN the Assignment_Module displays a new assignment in `ASSIGNED` state, it SHALL show a primary action button labelled "Navigate to Restaurant".
2. WHEN the partner taps "Navigate to Restaurant", THE Navigation_Module SHALL open the in-app map screen centred on the restaurant location with the partner's current position and a route polyline.
3. THE Assignment_Module SHALL display the delivery status progress bar reflecting `ASSIGNED` as the first active step.
4. THE Assignment_Module SHALL provide a secondary action to launch an external navigation app (Google Maps or Apple Maps) pre-filled with the restaurant coordinates.

**Backend mapping:** No backend call for this display state; restaurant coordinates come from the assignment detail (Gap 7).

### Requirement 17: In-App Navigation Map

**User Story:** As a delivery partner en route to a restaurant or customer, I want a live map showing my position, the destination, and an estimated route, so that I can navigate confidently.

#### Acceptance Criteria

1. WHEN the Navigation_Module is opened, it SHALL display a Google Maps Flutter map with the partner's current GPS position updating in real time, a destination marker, and a polyline representing the route.
2. THE Navigation_Module SHALL display the estimated distance (km) and ETA (minutes) to the current destination, updated when the partner's position changes by more than 30 meters.
3. THE Navigation_Module SHALL support two destination states: restaurant (pickup) and customer (delivery), switching automatically when the assignment advances from `ASSIGNED` to `PICKED_UP`.
4. THE Navigation_Module SHALL provide an external navigation button that launches Google Maps (Android/iOS) or Apple Maps (iOS) with the destination pre-filled.
5. IF Google Maps is not installed, THE Navigation_Module SHALL fall back to opening a browser-based maps URL.
6. THE Navigation_Module SHALL display the restaurant marker in a distinct color from the customer marker.
7. WHEN the device is offline, THE Navigation_Module SHALL display the last-known map tile cache and SHALL show an offline banner.

**Backend mapping:** No backend call for map rendering; partner position from the local `Location_Module` stream; destination coordinates from the locally cached assignment detail.

### Requirement 18: Confirm Order Pickup

**User Story:** As a delivery partner who has collected the order from the restaurant, I want to confirm pickup, so that the system updates the order status and the customer is notified.

#### Acceptance Criteria

1. WHEN the partner is in `ASSIGNED` state and taps the "Confirm Pickup" button on the assignment screen, THE Assignment_Module SHALL send `POST /api/delivery/assignments/{orderId}/picked-up`.
2. WHEN the pickup request returns HTTP 200, THE Assignment_Module SHALL update the displayed status to `PICKED_UP` and SHALL switch the Navigation_Module destination to the customer address.
3. WHILE the pickup request is in progress, THE Assignment_Module SHALL disable the button and SHALL display a loading indicator.
4. IF the pickup request returns a network error, THE Assignment_Module SHALL display an error message with a retry control and SHALL NOT advance the displayed status.
5. THE Assignment_Module SHALL prevent the "Confirm Pickup" button from being displayed when the assignment is already in `PICKED_UP` or `DELIVERED` state.

**Backend mapping:** `POST /api/delivery/assignments/{orderId}/picked-up` (202/200 OK; publishes `OrderPickedUpEvent` via outbox). Requires Gap 0 fix.

### Requirement 19: Confirm Order Delivery

**User Story:** As a delivery partner who has handed over the order to the customer, I want to confirm delivery, so that the order is marked complete and I become available for new assignments.

#### Acceptance Criteria

1. WHEN the partner is in `PICKED_UP` state and taps "Confirm Delivery", THE Assignment_Module SHALL send `POST /api/delivery/assignments/{orderId}/delivered`.
2. WHEN the delivery request returns HTTP 200, THE Assignment_Module SHALL clear the Active_Assignment, SHALL update the displayed status to `DELIVERED`, and SHALL display a delivery-complete summary card.
3. WHEN the delivery is confirmed, the backend SHALL automatically mark the partner as available again (handled by `completeDelivery` in `DeliveryAssignmentService`). The Delivery_App SHALL not send a separate online call.
4. WHILE the delivery request is in progress, THE Assignment_Module SHALL disable the "Confirm Delivery" button and SHALL display a loading indicator.
5. IF the delivery request returns a network error, THE Assignment_Module SHALL display an error with retry. The partner SHALL remain in `PICKED_UP` state.
6. WHEN the delivery-complete card is displayed, it SHALL show total delivery distance and a prompt to rate the delivery experience (client-side rating flagged — see Gap 8).

**Backend mapping:** `POST /api/delivery/assignments/{orderId}/delivered` (publishes `OrderDeliveredEvent` and marks partner available via outbox). Requires Gap 0 fix.

### Requirement 20: Delivery History

**User Story:** As a delivery partner, I want to view my past completed deliveries, so that I can track my performance over time.

#### Acceptance Criteria

1. WHEN a partner opens the History screen, THE History_Module SHALL display a paginated list of past completed deliveries in reverse chronological order.
2. Each history entry SHALL display the delivery date, order reference, pickup location, drop-off location, distance, and payout for that delivery.
3. WHEN the partner scrolls to within three items of the end of the loaded list AND more pages are available, THE History_Module SHALL load the next page and append results.
4. WHEN the history list is empty, THE History_Module SHALL display an empty-state message.
5. WHILE the history list is loading, THE History_Module SHALL display shimmer placeholder cards.
6. THE History_Module SHALL expose delivery history through a repository interface so that a backend endpoint can replace a local-cache implementation without changing screens.

**Backend mapping:** BACKEND GAP — see Gap 4 (no delivery history endpoint exists; local-cache MVP).

### Requirement 21: Earnings — Today

**User Story:** As a delivery partner, I want to see how much I have earned today, so that I can track my daily income.

#### Acceptance Criteria

1. WHEN the partner opens the Earnings screen or the home screen earnings card, THE Earnings_Module SHALL display the total earnings for the current calendar day.
2. THE Earnings_Module SHALL display the number of deliveries completed today alongside the earnings figure.
3. WHEN a new delivery is completed, THE Earnings_Module SHALL update the today-earnings figure without requiring a full screen reload.
4. THE Earnings_Module SHALL derive today's earnings from locally tracked completed deliveries until a server-backed earnings endpoint is available.

**Backend mapping:** BACKEND GAP — see Gap 5 (no earnings endpoint; computed client-side from locally tracked deliveries).

### Requirement 22: Earnings — Weekly and All-Time

**User Story:** As a delivery partner, I want to see my earnings for the current week and historically, so that I can understand my income trends.

#### Acceptance Criteria

1. THE Earnings_Module SHALL display a weekly earnings total for the current calendar week (Monday to Sunday).
2. THE Earnings_Module SHALL display a bar chart of daily earnings for the current week.
3. THE Earnings_Module SHALL display an all-time total deliveries count and total earnings figure.
4. THE Earnings_Module SHALL expose earnings data through a repository interface so that a backend earnings endpoint can replace local computation without changing screens.

**Backend mapping:** BACKEND GAP — see Gap 5 (no weekly/all-time earnings endpoint; computed client-side).

### Requirement 23: Partner Profile Display

**User Story:** As a delivery partner, I want to view my profile information, so that I can confirm the account details associated with my account.

#### Acceptance Criteria

1. WHEN the Profile screen opens, THE Profile_Module SHALL display the partner's full name, email, phone, and role sourced from the `PartnerSession`.
2. THE Profile_Module SHALL display the partner's vehicle type and license number where available in local storage.
3. WHERE profile editing is presented, THE Profile_Module SHALL display the editing controls in a disabled state and SHALL state that profile editing is not yet available.
4. THE Profile_Module SHALL expose profile read/update logic behind a repository interface so that a `GET`/`PUT /auth/delivery-person/me` endpoint can be connected without changing the screen.

**Backend mapping:** Profile sourced from JWT `PartnerSession`. A profile GET/PUT endpoint is a Backend_Gap — see Gap 2.

### Requirement 24: Notification Center

**User Story:** As a delivery partner, I want to see a history of all notifications I have received, so that I can review missed alerts.

#### Acceptance Criteria

1. WHEN the partner opens the Notifications screen, THE Notification_Module SHALL display all locally stored notifications in reverse chronological order.
2. WHEN a new push notification arrives, THE Notification_Module SHALL prepend it to the local notification list and SHALL mark it as unread.
3. WHEN the partner taps a notification referencing an assignment, THE Notification_Module SHALL deep-link to the Assignment screen for the referenced orderId.
4. WHEN all notifications are read, THE Notification_Module SHALL clear the unread badge on the notifications icon.
5. THE Notification_Module SHALL expose notification history through a repository interface so that a server-backed history can replace local storage without changing screens.

**Backend mapping:** BACKEND GAP — see Gap 6 (notification service is a stub; push delivery + local store MVP).

### Requirement 25: App Settings and Theme

**User Story:** As a delivery partner, I want to configure app settings including the display theme, so that the app matches my preference.

#### Acceptance Criteria

1. WHEN a partner selects light, dark, or system theme, THE Settings_Module SHALL persist the choice to local preferences.
2. WHEN the Delivery_App starts, THE Settings_Module SHALL apply the persisted theme, defaulting to the system theme when no preference is stored.
3. WHEN the partner changes the theme, THE Delivery_App SHALL apply it across all screens without requiring a restart.
4. THE Settings_Module SHALL provide a toggle for assignment push-notification sounds.
5. THE Settings_Module SHALL display a "Background Location" permission status indicator with a shortcut to device app settings.

**Backend mapping:** No backend call (local preferences via `SharedPreferences`).

### Requirement 26: Connectivity and Offline Handling

**User Story:** As a delivery partner in an area with poor signal, I want the app to behave predictably offline, so that I do not lose in-progress delivery data.

#### Acceptance Criteria

1. WHEN the device loses internet connectivity, THE Network_Layer SHALL surface a no-connection error and THE requesting screen SHALL display a banner indicating offline mode.
2. WHEN the device is offline AND the partner has an Active_Assignment, THE Assignment_Module SHALL continue to display the last-cached assignment details.
3. WHEN the device is offline AND a pickup or delivery confirmation is attempted, THE Assignment_Module SHALL queue the confirmation locally and SHALL retry it automatically when connectivity is restored.
4. WHEN connectivity is restored, THE Network_Layer SHALL notify all pending retry queues and SHALL resume GPS heartbeat submissions.
5. IF a queued pickup or delivery confirmation fails after three retries, THE Assignment_Module SHALL display an error requiring manual retry.

**Backend mapping:** Applies to all verified endpoints; offline queue targets `POST picked-up` and `POST delivered`.

### Requirement 27: Error Handling

**User Story:** As a delivery partner, I want every screen to handle errors clearly, so that I always know what happened and how to recover.

#### Acceptance Criteria

1. IF any request fails due to no internet, THEN the screen SHALL display a "No connection" message with a retry control.
2. IF any request exceeds the configured timeout of 15 seconds, THEN the screen SHALL display a "Request timed out" message with a retry control.
3. IF any request returns HTTP 5xx, THEN the screen SHALL display a "Server error" message with a retry control.
4. IF the GPS heartbeat fails more than three consecutive times, THEN THE Location_Module SHALL display a persistent warning on the home screen.
5. IF the assignment confirmation returns HTTP 409 (already processed), THEN THE Assignment_Module SHALL treat the response as successful and advance the local state.
6. IF the partner attempts to confirm pickup or delivery outside an active assignment state, THE Assignment_Module SHALL display a "No active assignment" message.
7. IF location permission is revoked while the partner is Online, THE Location_Module SHALL notify the partner and SHALL display a prompt to re-grant permission.

**Backend mapping:** Applies to all verified endpoints.

### Requirement 28: Push Notification Deep Linking

**User Story:** As a delivery partner, I want tapping a push notification to take me directly to the relevant screen in the app, so that I do not need to navigate manually.

#### Acceptance Criteria

1. WHEN the partner taps a delivery-assignment notification, THE Delivery_App SHALL route to the Assignment detail screen for the referenced orderId, authenticating first if the session has expired.
2. WHEN the partner taps a ready-for-pickup notification, THE Delivery_App SHALL route to the Navigation screen with the restaurant as destination.
3. WHEN the partner taps a delivery-reminder notification, THE Delivery_App SHALL route to the Navigation screen with the customer as destination.
4. WHEN the partner taps a generic system notification, THE Delivery_App SHALL route to the Notification Center.
5. THE Notification_Module SHALL handle deep links in foreground, background, and killed-app states using `firebase_messaging` and `flutter_local_notifications`.

**Backend mapping:** FCM data payload carries `type` and `orderId` for routing (Notification service stub — see Gap 6).

### Requirement 29: App Lifecycle Handling

**User Story:** As a delivery partner, I want the app to handle foreground/background transitions without losing my delivery state.

#### Acceptance Criteria

1. WHEN the Delivery_App moves to the background while Online, THE Location_Module SHALL transition from foreground GPS to background service mode automatically.
2. WHEN the Delivery_App returns to the foreground, THE Location_Module SHALL transition from background service to foreground GPS mode and SHALL reconcile any locally cached fixes.
3. WHEN the Delivery_App is relaunched after being killed while the partner was Online with an Active_Assignment, THE Assignment_Module SHALL restore the assignment from local cache and SHALL display it immediately.
4. THE Delivery_App SHALL register for `AppLifecycleState` changes and SHALL notify the Location_Module and Assignment_Module on each transition.

**Backend mapping:** No backend call for lifecycle transitions; relies on locally persisted state and background service.

### Requirement 30: Security and Token Storage

**User Story:** As a delivery partner, I want my credentials and token handled securely, so that my account cannot be compromised on a shared device.

#### Acceptance Criteria

1. THE Session_Manager SHALL store the JWT in `flutter_secure_storage` and SHALL never write it to plain preferences, logs, or shared storage.
2. THE Delivery_App SHALL exclude JWT values, passwords, latitude, and longitude from application logs.
3. WHEN the Network_Layer attaches the JWT to a request, it SHALL transmit the request over HTTPS only.
4. WHEN a partner logs out or the session is cleared due to HTTP 401, THE Session_Manager SHALL remove the JWT from secure storage and SHALL clear any in-memory session caches.
5. THE Location_Module SHALL validate that submitted coordinates fall within geographic bounds (`lat` -90 to 90, `lng` -180 to 180) before sending them to the backend.

**Backend mapping:** JWT enforced by API_Gateway filter; token issued by `POST /auth/login/delivery-person`.

### Requirement 31: Performance and Battery Optimization

**User Story:** As a delivery partner who relies on my phone battery throughout a shift, I want the app to be efficient so that it does not drain my battery.

#### Acceptance Criteria

1. THE Location_Module SHALL use balanced-power mode when no Active_Assignment exists and high-accuracy mode only during active deliveries.
2. THE Location_Module SHALL apply a distance filter of 15 meters — no heartbeat SHALL be submitted when the partner has not moved that distance since the last submission.
3. THE Location_Module SHALL increase the heartbeat interval to 30 seconds when battery is below 15% and return to 10 seconds when battery recovers above 20%.
4. THE Delivery_App SHALL dispose of all Riverpod providers that are not needed outside their originating screen using `autoDispose`.
5. THE Navigation_Module SHALL cache map tiles locally to avoid repeated tile downloads on the same route.
6. All list screens SHALL use lazy loading with `ListView.builder` and SHALL not eagerly render off-screen items.

**Backend mapping:** Heartbeat calls `POST /api/delivery/partners/{id}/location`.

### Requirement 32: Accessibility

**User Story:** As a delivery partner who relies on assistive technology, I want the app to be accessible so that I can use it safely while managing my device.

#### Acceptance Criteria

1. THE Delivery_App SHALL provide semantic labels for every interactive control and every informational icon.
2. THE Delivery_App SHALL render text using scalable units that respond to the OS text-scaling setting.
3. THE Delivery_App SHALL maintain a contrast ratio of at least 4.5:1 for body text in both light and dark themes.
4. Every interactive control SHALL have a minimum touch target of 48 × 48 logical pixels.
5. THE Delivery_App SHALL announce assignment arrival and status-change events via accessibility notifications.

**Backend mapping:** Not applicable (client-side presentation).

### Requirement 33: Responsiveness and Layout

**User Story:** As a delivery partner using a variety of Android and iOS devices, I want the layout to adapt so that the app is usable on all screen sizes.

#### Acceptance Criteria

1. THE Delivery_App SHALL render correctly on screens from 360dp to 480dp width (standard phones).
2. THE Delivery_App SHALL support tablet layouts at 600dp+ width with expanded side panels.
3. WHEN device orientation changes, THE Delivery_App SHALL preserve the current screen state and re-layout content without a full reload.

**Backend mapping:** Not applicable (client-side presentation).

---

## Cross-Cutting and Non-Functional Requirements

### Requirement 34: Networking and Error Classification

#### Acceptance Criteria

1. THE Network_Layer SHALL classify all outbound request failures into exactly one `Failure` type: `NoConnection`, `Timeout`, `Server`, `Validation`, `Conflict`, `RateLimit`, `InvalidCredentials`, `SessionExpired`, or `Unknown`.
2. THE Network_Layer SHALL apply a 15-second timeout to all requests.
3. THE Network_Layer SHALL cancel in-flight requests when the originating screen or provider is disposed.
4. THE Network_Layer SHALL expose a single 401 interception point for future refresh-flow integration.

**Backend mapping:** Applies to all seven verified endpoints.

### Requirement 35: Location DTO Validation

#### Acceptance Criteria

1. THE Location_Module SHALL reject any GPS fix with `latitude` outside [-90, 90] or `longitude` outside [-180, 180] before submission.
2. THE Location_Module SHALL reject GPS fixes with a reported accuracy worse than 50 meters.
3. THE Location_Module SHALL round coordinate values to six decimal places before submission.

**Backend mapping:** `LocationUpdateRequest` validated server-side (min/max annotations); client-side validation prevents unnecessary 400 responses.

---

## Backend Gaps & Resolution Strategy

### Gap 0 — Gateway Routing Mismatch (CRITICAL INFRASTRUCTURE)

**Category: Requires backend fix before any delivery endpoint is reachable through the gateway.**

The API Gateway routes `/deliveries/**` and `/delivery-partners/**` (application.yml), but the Delivery Service controllers use `@RequestMapping("/api/delivery/assignments")` and `@RequestMapping("/api/delivery/partners")`. No request from the Delivery_App can reach these endpoints through the gateway as currently configured.

**Recommended fix:** Update `application.yml` to route `/api/delivery/**` to `http://localhost:8086`. Alternatively, change the controller base paths to `/deliveries/**` and `/delivery-partners/**`. Until this is resolved, all five delivery endpoints are unreachable through the gateway.

**Affects:** Req 6, 7, 10, 11, 18, 19.

---

### Category A — Client-side MVP (deliverable now; server sync flagged for later)

| # | Gap | Why no endpoint | Recommended resolution | Affects |
|---|-----|-----------------|------------------------|---------|
| 3 | Current active assignment fetch | No `GET /api/delivery/assignments/current` or any GET endpoint on the delivery service | Cache assignment details locally from push notification payload; display cached data. Flag `GET /api/delivery/assignments/active` for backend. | Req 15, 16 |
| 5 | Earnings | No earnings endpoint | Track completed deliveries locally; compute today/weekly/all-time earnings client-side. Flag `GET /api/delivery/earnings?period=` for backend. | Req 21, 22 |
| 6 | Notification history | Notification service is an empty stub | Push delivery + local notification store. Flag notification-history endpoint for backend. | Req 13, 14, 24 |
| 8 | Post-delivery rating | No rating endpoint | Show completion card only; flag partner-rates-customer as future feature. | Req 19 |

### Category B — Requires new backend endpoint

| # | Gap | Why no endpoint | Recommended resolution | Affects |
|---|-----|-----------------|------------------------|---------|
| 1 | Token refresh | No `/auth/refresh` endpoint; single-token flow | Build 401 interceptor with single seam; current behavior: clear session → login. Add `POST /auth/refresh` to backend. | Req 3, 4, 5 |
| 2 | Delivery partner profile GET/PUT | No `/auth/delivery-person/me` endpoint | Display from JWT claims; editing disabled. Add `GET`/`PUT /auth/delivery-person/me`. `vehicleType`/`licenseNumber` also missing from `RegisterDeliveryPersonRequest` DTO. | Req 1, 23 |
| 4 | Delivery history | No delivery history endpoint | Local-cache MVP from completed deliveries. Add `GET /api/delivery/assignments/history?page=&size=`. | Req 20 |
| 7 | Assignment detail (addresses) | `DeliveryAssignment` entity stores only orderId/restaurantId/customerId with no address fields; `DeliveryAssignedEvent` payload contains only orderId, partnerId, assignedAt — no addresses | Push payload must be enriched with restaurant name/address and customer address, or a `GET /api/delivery/assignments/{orderId}/detail` endpoint must be added returning enriched assignment data. | Req 15, 16, 17, 18, 19 |
| 9 | Partner-ID trust | `/api/delivery/partners/{id}/*` uses a path variable that is not validated against the authenticated JWT `X-User-Id` | Add a gateway filter or service-level guard that compares the path `{id}` with the `X-User-Id` injected header to prevent cross-partner manipulation. | Req 6, 7, 10, 11 |

### Notes on Real-Time Readiness

Requirements 13, 14, and 24 share the same repository abstraction (`NotificationRepository`), keeping the current push-plus-local-store implementation swappable for a backend notification-history endpoint without restructuring the consuming screens.

Requirement 17 (Navigation_Module) uses a `TrackingRepository` stream abstraction so that a real-time WebSocket channel can replace polling without restructuring the navigation screen.
