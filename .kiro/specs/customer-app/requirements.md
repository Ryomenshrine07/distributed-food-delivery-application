# Requirements Document

## Introduction

This document specifies the requirements for the **Customer App**, the customer-facing mobile application of an existing Food Delivery Platform. The Customer App is one of three frontend clients (alongside a Delivery app and an Admin dashboard, both out of scope for this spec).

The application is built with Flutter and Material 3, using Riverpod for state management, Dio for networking, GoRouter for routing, and `flutter_secure_storage` together with `SharedPreferences` for storage. The codebase follows Clean Architecture with a feature-first folder structure and targets the directory `frontend/Customer_app`.

The platform backend already exists as a set of Spring Boot microservices behind a Spring Cloud Gateway. The gateway enforces JWT authentication on all routes except `/auth/**` and injects identity headers (`X-User-Id`, `X-User-Email`, `X-User-Role`, `X-User-Name`, `X-User-Phone`) into downstream requests. Because the backend is fixed, **every requirement in this document maps to an existing REST endpoint where one exists**. Where a customer feature cannot be served by an existing endpoint, the requirement references a documented entry in the **Backend Gaps & Resolution Strategy** section rather than assuming a new endpoint.

This is a requirements document only. It does not contain design or implementation detail. It is intended for review and approval before design begins.

## Glossary

### System Components
- **Customer_App**: The complete Flutter customer mobile application described by this document.
- **Auth_Module**: The component of the Customer_App responsible for registration, login, logout, and credential validation.
- **Session_Manager**: The component responsible for storing, retrieving, attaching, and clearing the authentication token and derived identity claims.
- **Network_Layer**: The Dio-based component responsible for issuing HTTP requests, attaching headers, applying timeouts, cancelling requests, and surfacing transport errors.
- **Discovery_Module**: The component responsible for the home screen, restaurant listing, search, and cuisine/category filtering.
- **Restaurant_Module**: The component responsible for restaurant detail and menu browsing.
- **Cart_Module**: The component responsible for the local cart and its display-only pricing.
- **Checkout_Module**: The component responsible for address selection, the payment step, and order placement.
- **Orders_Module**: The component responsible for listing the customer's active and previous orders.
- **Tracking_Module**: The component responsible for displaying an order's status lifecycle.
- **Profile_Module**: The component responsible for displaying the customer's identity information.
- **Address_Module**: The component responsible for managing locally stored delivery addresses.
- **Favorites_Module**: The component responsible for managing locally stored favorite restaurants.
- **Notification_Module**: The component responsible for receiving push notifications and displaying a local notification list.
- **Settings_Module**: The component responsible for theme selection and other client preferences.

### Domain Terms
- **API_Gateway**: The Spring Cloud Gateway exposing the backend at a single base URL and enforcing JWT authentication.
- **JWT**: The single bearer token returned by the auth service on successful login.
- **Identity_Claims**: The user attributes encoded in the JWT (user id, email, role, name, phone) used by the Customer_App for display and by the backend for authorization.
- **ApiResponse**: The restaurant service response envelope of the form `{success, message, data}`.
- **Page_Response**: A paginated payload containing a content list plus pagination metadata (page number, page size, total elements, total pages, last-page flag).
- **Order_Status**: One of the nine backend lifecycle values: `PENDING_PAYMENT`, `CONFIRMED`, `PREPARING`, `READY_FOR_PICKUP`, `DELIVERY_PARTNER_ASSIGNED`, `OUT_FOR_DELIVERY`, `DELIVERED`, `CANCELLED`, `FAILED`.
- **Active_Order**: An order whose Order_Status is not `DELIVERED`, `CANCELLED`, or `FAILED`.
- **Previous_Order**: An order whose Order_Status is `DELIVERED`, `CANCELLED`, or `FAILED`.
- **Delivery_Location**: The structured destination object `{address, latitude, longitude}` submitted at checkout.
- **Backend_Gap**: A required customer capability with no existing backend endpoint, tracked in the Backend Gaps & Resolution Strategy section.

### Backend Endpoint Reference (verified)
- `POST /auth/register/customer` — register a customer; returns user record; rate limited to 3 per hour per IP.
- `POST /auth/login/customer` — authenticate a customer; returns JWT and Identity_Claims; rate limited to 5 per minute per IP.
- `GET /restaurants?city=&category=&page=&size=` — paginated public restaurant list.
- `GET /restaurants/search?keyword=&page=&size=` — paginated public restaurant search.
- `GET /restaurants/{id}` — public restaurant detail.
- `GET /restaurants/{restaurantId}/menu` — public restaurant detail with nested categories and items.
- `POST /orders` — create an order (CUSTOMER role; identity taken from injected headers).
- `GET /orders/{orderId}` — fetch a single order (CUSTOMER role).
- `GET /orders/my-orders` — list the authenticated customer's orders (CUSTOMER role).
- `PATCH /orders/{orderId}/cancel` — cancel an order (CUSTOMER role).

---

## Requirements

### Requirement 1: Customer Registration

**User Story:** As a prospective customer, I want to create an account with my email, password, name, and phone number, so that I can place food orders.

#### Acceptance Criteria

1. WHEN a guest submits the registration form with a valid email, a password of 8 to 25 characters, a non-empty full name, and an Indian phone number matching the pattern `^[6-9]\d{9}$`, THE Auth_Module SHALL send a registration request to `POST /auth/register/customer`.
2. WHEN the registration request returns HTTP 201, THE Auth_Module SHALL display a registration-success confirmation and route the customer to the login screen.
3. IF any registration field fails client-side validation, THEN THE Auth_Module SHALL display a field-level validation message and SHALL withhold the registration request until all fields are valid.
4. IF the registration request returns HTTP 409 or a duplicate-account error, THEN THE Auth_Module SHALL display a message stating that the email is already registered.
5. IF the registration request returns HTTP 429, THEN THE Auth_Module SHALL display a message stating that the registration attempt limit is reached and SHALL advise the customer to retry later.
6. IF the registration request returns HTTP 400 with field errors, THEN THE Auth_Module SHALL display the server-provided validation messages mapped to their corresponding fields.

**Backend mapping:** `POST /auth/register/customer` (request body: email, password 8–25, fullName, phone `^[6-9]\d{9}$`; rate limit 3/hour/IP → 429).

### Requirement 2: Customer Login

**User Story:** As a registered customer, I want to log in with my email and password, so that I can access my account and order food.

#### Acceptance Criteria

1. WHEN a guest submits the login form with a valid email and a password of 8 to 15 characters, THE Auth_Module SHALL send an authentication request to `POST /auth/login/customer`.
2. WHEN the authentication request returns HTTP 200, THE Session_Manager SHALL persist the returned JWT in secure storage and SHALL route the customer to the home screen.
3. IF the authentication request returns HTTP 401, THEN THE Auth_Module SHALL display a message stating that the email or password is incorrect.
4. IF the authentication request returns HTTP 429, THEN THE Auth_Module SHALL display a message stating that the login attempt limit is reached and SHALL advise the customer to retry after one minute.
5. WHILE the authentication request is in progress, THE Auth_Module SHALL display a loading indicator on the login control and SHALL block duplicate submissions.

**Backend mapping:** `POST /auth/login/customer` (request body: email, password 8–15; response: token, userId, fullName, email, role; rate limit 5/min/IP → 429).

### Requirement 3: Session Persistence and Token Attachment

**User Story:** As a returning customer, I want the app to remember my logged-in session, so that I do not have to sign in every time I open the app.

#### Acceptance Criteria

1. WHEN the Customer_App starts AND a stored JWT is present, THE Session_Manager SHALL load the token and route the customer to the home screen without requiring re-entry of credentials.
2. WHEN the Customer_App starts AND no stored JWT is present, THE Session_Manager SHALL route the customer to the login screen.
3. WHEN the Network_Layer issues a request to any path other than `/auth/**`, THE Network_Layer SHALL attach the stored JWT as an `Authorization: Bearer <token>` header.
4. THE Session_Manager SHALL expose the Identity_Claims (user id, email, role, name, phone) decoded from the stored JWT for display by other components.
5. WHERE a stored JWT is expired based on its embedded expiry claim, THE Session_Manager SHALL treat the session as unauthenticated on app start and SHALL route the customer to the login screen.

**Backend mapping:** API_Gateway global JWT filter (all non-`/auth/**` routes require `Authorization: Bearer <token>`); Identity_Claims sourced from the login JWT. Token-refresh handling is a Backend_Gap — see Gap 1.

### Requirement 4: Session Expiry Handling on Unauthorized Responses

**User Story:** As a customer whose session has expired, I want the app to handle the expiry gracefully, so that I am not left on a broken screen.

#### Acceptance Criteria

1. IF any authenticated request returns HTTP 401, THEN THE Session_Manager SHALL clear the stored JWT and SHALL route the customer to the login screen.
2. WHEN the Session_Manager clears the session due to an HTTP 401, THE Auth_Module SHALL display a message stating that the session has ended and that the customer must sign in again.
3. THE Network_Layer SHALL expose a single interception point for HTTP 401 handling so that a future token-refresh flow can be introduced without restructuring request code.

**Backend mapping:** BACKEND GAP — see Gap 1 (no `/auth/refresh` endpoint and no refresh token; current behavior is clear-session-and-relogin).

### Requirement 5: Logout

**User Story:** As a logged-in customer, I want to log out, so that my account is protected on a shared device.

#### Acceptance Criteria

1. WHEN a logged-in customer confirms logout, THE Session_Manager SHALL delete the stored JWT and all cached Identity_Claims from device storage.
2. WHEN logout completes, THE Auth_Module SHALL route the customer to the login screen and SHALL remove authenticated screens from the navigation history.

**Backend mapping:** No backend call (stateless JWT; logout is local token deletion). Server-side token revocation is a Backend_Gap — see Gap 1.

### Requirement 6: Forgot Password and OTP (Flagged)

**User Story:** As a customer who forgot my password, I want to reset it, so that I can regain access to my account.

#### Acceptance Criteria

1. WHERE password recovery is enabled in the build configuration, THE Auth_Module SHALL present a forgot-password entry point on the login screen.
2. WHILE no backend password-recovery endpoint is available, THE Auth_Module SHALL present the forgot-password and OTP screens in a disabled "coming soon" state and SHALL state that recovery is not yet available.
3. THE Auth_Module SHALL isolate password-recovery logic behind a dedicated repository interface so that backend recovery and OTP endpoints can be connected without changing the screens.

**Backend mapping:** BACKEND GAP — see Gap 2 (no forgot-password or OTP endpoints exist; screens are flagged disabled).

### Requirement 7: Restaurant Discovery and Home Listing

**User Story:** As a customer, I want to browse a list of restaurants on the home screen, so that I can decide where to order from.

#### Acceptance Criteria

1. WHEN the home screen opens, THE Discovery_Module SHALL request the first page of restaurants from `GET /restaurants` using a page size of 10.
2. WHEN the restaurant list response is received, THE Discovery_Module SHALL display each restaurant's name, cuisine, rating, average delivery time, and open-or-closed status.
3. WHILE the customer scrolls AND additional pages are available according to the Page_Response metadata, THE Discovery_Module SHALL request the next page and SHALL append the results to the existing list.
4. WHERE the customer applies a city filter, THE Discovery_Module SHALL include the `city` query parameter in the restaurant list request.
5. WHERE the customer applies a cuisine or category filter, THE Discovery_Module SHALL include the `category` query parameter in the restaurant list request.
6. WHEN the restaurant list response contains zero restaurants, THE Discovery_Module SHALL display an empty-state message indicating that no restaurants are available.

**Backend mapping:** `GET /restaurants?city=&category=&page=&size=` (public, paginated, default size 10). The catalog of selectable cuisines/categories for filter chips is a Backend_Gap — see Gap 11.

### Requirement 8: Restaurant Search

**User Story:** As a customer, I want to search for restaurants by keyword, so that I can quickly find a specific place or dish type.

#### Acceptance Criteria

1. WHEN the customer enters a search keyword and pauses for 400 milliseconds, THE Discovery_Module SHALL request results from `GET /restaurants/search` using the entered keyword and a page size of 10.
2. WHEN the customer submits a new search keyword while a prior search request is in flight, THE Network_Layer SHALL cancel the prior search request before issuing the new request.
3. WHILE the customer scrolls the search results AND additional pages are available, THE Discovery_Module SHALL request and append the next page of search results.
4. WHEN a search returns zero results, THE Discovery_Module SHALL display an empty-state message indicating that no restaurants match the keyword.

**Backend mapping:** `GET /restaurants/search?keyword=&page=&size=` (public, paginated).

### Requirement 9: Promotions and Recommended Sections

**User Story:** As a customer, I want to see promotions and recommended restaurants, so that I can discover relevant options faster.

#### Acceptance Criteria

1. THE Discovery_Module SHALL display a recommended section derived from the restaurant list ordered by rating in descending order.
2. WHERE curated promotional content is configured in the client, THE Discovery_Module SHALL display a promotions section using that configured content.
3. WHEN a customer selects a recommended restaurant, THE Discovery_Module SHALL route to the restaurant detail screen for the selected restaurant.

**Backend mapping:** Recommended derived client-side from `GET /restaurants`; promotions are curated client content. Server-driven promotions and recommendations are a Backend_Gap — see Gap 9.

### Requirement 10: Restaurant Detail and Menu Browsing

**User Story:** As a customer, I want to view a restaurant's details and full menu, so that I can choose items to order.

#### Acceptance Criteria

1. WHEN a customer opens a restaurant, THE Restaurant_Module SHALL request the restaurant menu from `GET /restaurants/{restaurantId}/menu`.
2. WHEN the menu response is received, THE Restaurant_Module SHALL display the restaurant header information and the menu grouped by category with each item's name, description, price, vegetarian indicator, and availability.
3. THE Restaurant_Module SHALL display the restaurant's rating value as read-only.
4. WHERE a menu item's availability flag is false, THE Restaurant_Module SHALL display the item in a disabled state and SHALL prevent adding the item to the cart.
5. WHEN a customer enters text in the in-menu search field, THE Restaurant_Module SHALL filter the displayed menu items to those whose name or description contains the entered text.

**Backend mapping:** `GET /restaurants/{restaurantId}/menu` and `GET /restaurants/{id}` (public; `RestaurantResponse` with nested categories and items). Rating is display-only; review submission is a Backend_Gap — see Gap 8.

### Requirement 11: Add Items to Cart

**User Story:** As a customer, I want to add available menu items to a cart, so that I can prepare an order from one restaurant.

#### Acceptance Criteria

1. WHEN a customer adds an available menu item to the cart, THE Cart_Module SHALL store the item's menu item id, item name, and quantity in the local cart.
2. IF a customer adds an item from a restaurant different from the restaurant of the current cart contents, THEN THE Cart_Module SHALL prompt the customer to confirm replacing the cart before adding the new item.
3. WHEN a customer increases or decreases an item quantity, THE Cart_Module SHALL update the stored quantity for that item.
4. WHEN a customer decreases an item quantity to zero, THE Cart_Module SHALL remove the item from the cart.

**Backend mapping:** No backend call (cart is local; item identity from `GET /restaurants/{restaurantId}/menu`). Order item fields align with `POST /orders` (`menuItemId`, `itemName`, `quantity`).

### Requirement 12: Cart Review and Display-Only Pricing

**User Story:** As a customer, I want to review my cart with item quantities and an indicative price summary, so that I understand my selection before checkout.

#### Acceptance Criteria

1. THE Cart_Module SHALL display each cart item's name, unit price from the menu, quantity, and computed line total for display purposes.
2. THE Cart_Module SHALL display an indicative subtotal, delivery fee, tax, and total, and SHALL label the price summary as indicative and subject to confirmation by the server.
3. WHERE a coupon entry field is enabled in the client, THE Cart_Module SHALL present a coupon input control without applying any server-side discount.
4. WHEN the cart contains at least one item, THE Cart_Module SHALL enable the control that proceeds to checkout.
5. WHILE the cart is empty, THE Cart_Module SHALL display an empty-cart message and SHALL disable the control that proceeds to checkout.

**Backend mapping:** Display-only; authoritative subtotal, deliveryFee, tax, and totalAmount are computed server-side and returned by `POST /orders`. Coupon redemption is a Backend_Gap — see Gap 12.

### Requirement 13: Checkout Address Selection

**User Story:** As a customer, I want to choose a delivery address at checkout, so that my order is delivered to the right place.

#### Acceptance Criteria

1. WHEN the checkout screen opens, THE Checkout_Module SHALL display the customer's locally stored delivery addresses for selection.
2. WHEN a customer selects a delivery address, THE Checkout_Module SHALL populate the Delivery_Location with the selected address text, latitude, and longitude, and SHALL populate the delivery address text field.
3. IF no delivery address is selected, THEN THE Checkout_Module SHALL disable order placement and SHALL prompt the customer to select or add an address.
4. WHEN a customer adds a new address at checkout, THE Address_Module SHALL persist the new address to local storage and THE Checkout_Module SHALL select the new address.

**Backend mapping:** Local address storage; values are submitted inline in `POST /orders` (`deliveryLocation{address,latitude,longitude}` and `deliveryAddress`). Server-synced saved addresses are a Backend_Gap — see Gap 4.

### Requirement 14: Checkout Payment Step

**User Story:** As a customer, I want to complete a payment step during checkout, so that my order can be confirmed and prepared.

#### Acceptance Criteria

1. WHEN a customer reaches the payment step, THE Checkout_Module SHALL present the payment step through a payment repository interface that can be connected to a real payment gateway without changing the checkout screens.
2. WHEN a customer confirms the payment step, THE Checkout_Module SHALL place the order and SHALL rely on automatic server-side payment confirmation rather than issuing a separate client payment call.
3. WHILE a placed order remains in the `PENDING_PAYMENT` state, THE Checkout_Module SHALL poll the order status until the status leaves `PENDING_PAYMENT`, reaching `CONFIRMED` under normal processing or `FAILED` on payment failure.
4. THE Checkout_Module SHALL treat the order's server-returned Order_Status as the authoritative payment outcome.

**Backend mapping:** `POST /orders` creates the order in `PENDING_PAYMENT`; the backend payment service auto-confirms it through the existing Kafka outbox choreography (simulated approval, no real gateway), driving the order to `CONFIRMED` (or `FAILED` if payment processing fails). No new backend endpoint is required; the `PaymentRepository` stays swappable for a future real payment gateway — see Gap 3.

### Requirement 15: Place Order

**User Story:** As a customer, I want to place my order, so that the restaurant can begin preparing my food.

#### Acceptance Criteria

1. WHEN a customer confirms order placement with a selected address and a non-empty cart, THE Checkout_Module SHALL send a request to `POST /orders` containing the restaurant id, the Delivery_Location, the delivery address text, and the list of items with menu item id, item name, and quantity.
2. THE Checkout_Module SHALL exclude any customer identifier from the order request body and SHALL rely on the injected identity headers for customer identity.
3. WHEN the order request returns HTTP 201, THE Checkout_Module SHALL clear the local cart and SHALL route the customer to the order tracking screen for the created order.
4. WHEN the order response is received, THE Checkout_Module SHALL display the server-computed subtotal, delivery fee, tax, and total amount as the authoritative pricing.
5. IF the order request returns HTTP 400, THEN THE Checkout_Module SHALL display the server-provided validation message and SHALL keep the cart contents intact.

**Backend mapping:** `POST /orders` (CUSTOMER role; identity from `X-User-*` headers; server computes pricing and returns `OrderResponse` with `PENDING_PAYMENT` status).

### Requirement 16: Order History — Active and Previous

**User Story:** As a customer, I want to see my active and previous orders, so that I can track current deliveries and review past purchases.

#### Acceptance Criteria

1. WHEN the orders screen opens, THE Orders_Module SHALL request the customer's orders from `GET /orders/my-orders`.
2. WHEN the orders response is received, THE Orders_Module SHALL display Active_Order entries and Previous_Order entries in separate sections.
3. THE Orders_Module SHALL classify each order as an Active_Order when its Order_Status is not `DELIVERED`, `CANCELLED`, or `FAILED`, and as a Previous_Order otherwise.
4. WHEN a customer selects an order, THE Orders_Module SHALL route to the order tracking screen for the selected order.
5. WHEN the orders response contains zero orders, THE Orders_Module SHALL display an empty-state message indicating that no orders exist.

**Backend mapping:** `GET /orders/my-orders` (CUSTOMER role; returns `List<OrderResponse>`). Active/previous partitioning is performed client-side; no server-side status filter parameter exists.

### Requirement 17: Order Tracking Across the Status Lifecycle

**User Story:** As a customer, I want to track an order through its lifecycle, so that I know its current status.

#### Acceptance Criteria

1. WHEN the tracking screen opens for an order, THE Tracking_Module SHALL request the order from `GET /orders/{orderId}` and SHALL display the current Order_Status.
2. THE Tracking_Module SHALL render a lifecycle representation covering all nine Order_Status values: `PENDING_PAYMENT`, `CONFIRMED`, `PREPARING`, `READY_FOR_PICKUP`, `DELIVERY_PARTNER_ASSIGNED`, `OUT_FOR_DELIVERY`, `DELIVERED`, `CANCELLED`, and `FAILED`.
3. WHILE the displayed order is an Active_Order, THE Tracking_Module SHALL refresh the order from `GET /orders/{orderId}` at an interval of 15 seconds.
4. WHEN the displayed order reaches `DELIVERED`, `CANCELLED`, or `FAILED`, THE Tracking_Module SHALL stop the refresh interval.
5. THE Tracking_Module SHALL obtain order updates through a stream-based repository abstraction so that a real-time transport can replace polling without restructuring the tracking screen.
6. WHERE the order is in a customer-cancellable state, THE Tracking_Module SHALL present a cancel control that sends a request to `PATCH /orders/{orderId}/cancel`.
7. IF the cancel request returns an error status, THEN THE Tracking_Module SHALL display the server-provided message and SHALL retain the current displayed status.

**Backend mapping:** `GET /orders/{orderId}` (polling) and `PATCH /orders/{orderId}/cancel` (CUSTOMER role). Live delivery-partner location on a map is a Backend_Gap — see Gap 10.

### Requirement 18: Profile Display

**User Story:** As a customer, I want to view my profile information, so that I can confirm the account details associated with my orders.

#### Acceptance Criteria

1. WHEN the profile screen opens, THE Profile_Module SHALL display the full name, email, phone, and role from the Identity_Claims provided by the Session_Manager.
2. WHERE profile editing is presented, THE Profile_Module SHALL display the editing controls in a disabled state and SHALL state that profile editing is not yet available.
3. THE Profile_Module SHALL isolate profile read and update logic behind a repository interface so that profile endpoints can be connected without changing the screen.

**Backend mapping:** Profile display sourced from the login JWT / Identity_Claims. Profile read/edit endpoints (for example `GET`/`PUT /auth/me`) are a Backend_Gap — see Gap 7.

### Requirement 19: Saved Delivery Addresses

**User Story:** As a customer, I want to save and manage delivery addresses, so that I can reuse them at checkout.

#### Acceptance Criteria

1. WHEN a customer saves a delivery address, THE Address_Module SHALL persist the address text, latitude, and longitude to local device storage.
2. THE Address_Module SHALL display all locally stored addresses in the address management screen.
3. WHEN a customer deletes a saved address, THE Address_Module SHALL remove the address from local device storage.
4. WHEN a customer designates a saved address as default, THE Address_Module SHALL mark that address as the default selection for checkout.
5. THE Address_Module SHALL expose stored addresses through a repository interface so that a server-backed address store can replace local storage without changing the screens.

**Backend mapping:** BACKEND GAP — see Gap 4 (no address endpoint; local persistence MVP; addresses passed inline into `POST /orders`).

### Requirement 20: Favorite Restaurants

**User Story:** As a customer, I want to mark restaurants as favorites, so that I can return to them quickly.

#### Acceptance Criteria

1. WHEN a customer marks a restaurant as a favorite, THE Favorites_Module SHALL persist the restaurant id to local device storage.
2. WHEN a customer removes a restaurant from favorites, THE Favorites_Module SHALL delete the restaurant id from local device storage.
3. THE Favorites_Module SHALL display the favorited restaurants by resolving the stored restaurant ids against restaurant data from `GET /restaurants/{id}`.
4. THE Favorites_Module SHALL expose favorites through a repository interface so that a server-backed favorites store can replace local storage without changing the screens.

**Backend mapping:** BACKEND GAP — see Gap 5 (no favorites endpoint; local persistence MVP). Restaurant data resolved via `GET /restaurants/{id}`.

### Requirement 21: Notifications

**User Story:** As a customer, I want to receive notifications about my orders, so that I stay informed about their progress.

#### Acceptance Criteria

1. WHEN the Customer_App receives a push notification, THE Notification_Module SHALL store the notification content in a local notification list and SHALL display the notification to the customer.
2. WHEN a customer opens the notifications screen, THE Notification_Module SHALL display the locally stored notifications in reverse chronological order.
3. WHEN a customer opens a notification that references an order, THE Notification_Module SHALL route to the tracking screen for the referenced order.
4. THE Notification_Module SHALL expose notification history through a repository interface so that a server-backed notification history can replace local storage without changing the screen.

**Backend mapping:** BACKEND GAP — see Gap 6 (notification service is Kafka-only with no fetch/history endpoint; push delivery plus local store MVP).

### Requirement 22: Settings and Theme Selection

**User Story:** As a customer, I want to adjust app settings including the theme, so that the app matches my preference.

#### Acceptance Criteria

1. WHEN a customer selects light, dark, or system theme, THE Settings_Module SHALL persist the selected theme mode to local preferences.
2. WHEN the Customer_App starts, THE Settings_Module SHALL apply the persisted theme mode, defaulting to the system theme when no preference is stored.
3. WHEN a customer changes the theme mode, THE Customer_App SHALL apply the selected theme to all screens without requiring a restart.

**Backend mapping:** No backend call (local preference via `SharedPreferences`).

---

## Cross-Cutting and Non-Functional Requirements

### Requirement 23: Networking and Error Handling

**User Story:** As a customer, I want the app to handle network and server problems clearly, so that I always understand what is happening and what to do next.

#### Acceptance Criteria

1. IF a request fails because no internet connection is available, THEN THE Network_Layer SHALL surface a no-connection error and THE requesting screen SHALL display a no-connection message with a retry control.
2. IF a request exceeds the configured timeout of 15 seconds, THEN THE Network_Layer SHALL cancel the request and surface a timeout error to the requesting screen.
3. IF a request returns an HTTP 5xx status, THEN THE requesting screen SHALL display a server-error message with a retry control.
4. IF a request returns an HTTP 4xx status other than 401, THEN THE requesting screen SHALL display the server-provided message mapped to the relevant fields where field errors are present.
5. WHILE a data request is in progress, THE requesting screen SHALL display a loading state.
6. WHEN a data request returns an empty result set, THE requesting screen SHALL display an empty state distinct from the error state.
7. WHEN a customer activates a retry control after a failed request, THE requesting screen SHALL reissue the failed request.
8. WHEN a screen that issued a request is dismissed before the response arrives, THE Network_Layer SHALL cancel the associated in-flight request.

**Backend mapping:** Applies to all endpoints in the Backend Endpoint Reference; HTTP 401 handling defers to Requirement 4.

### Requirement 24: ApiResponse and Pagination Parsing

**User Story:** As a customer, I want restaurant data to load correctly regardless of payload shape, so that screens render accurate information.

#### Acceptance Criteria

1. WHEN the Network_Layer receives a restaurant-service response, THE Network_Layer SHALL parse the `ApiResponse` envelope and SHALL extract the `data` payload for use by the requesting component.
2. IF an `ApiResponse` envelope reports `success` as false, THEN THE requesting screen SHALL display the envelope `message` as an error.
3. WHEN the Network_Layer receives a Page_Response, THE Network_Layer SHALL parse the content list and the pagination metadata including the last-page indicator.
4. FOR ALL restaurant, menu, and order data models, decoding a payload into a model and then encoding the model SHALL produce a payload equivalent to the original for all round-tripped fields (round-trip property).

**Backend mapping:** `ApiResponse<T>{success,message,data}` envelope from the restaurant service; Page_Response from `GET /restaurants` and `GET /restaurants/search`; `OrderResponse` from the order service.

### Requirement 25: Security and Token Storage

**User Story:** As a customer, I want my credentials and token handled securely, so that my account cannot be easily compromised on my device.

#### Acceptance Criteria

1. THE Session_Manager SHALL store the JWT in `flutter_secure_storage` rather than in plain preferences.
2. THE Customer_App SHALL exclude the JWT value and password values from application logs.
3. WHEN the Network_Layer attaches the JWT to a request, THE Network_Layer SHALL transmit the request over HTTPS.
4. WHEN a customer logs out or the session is cleared due to an HTTP 401, THE Session_Manager SHALL remove the JWT from secure storage.

**Backend mapping:** Token issued by `POST /auth/login/customer`; enforced by the API_Gateway JWT filter on all non-`/auth/**` routes.

### Requirement 26: Performance and Rendering

**User Story:** As a customer, I want lists and images to load smoothly, so that browsing feels responsive.

#### Acceptance Criteria

1. THE Discovery_Module SHALL load restaurant lists using pagination with a page size of 10 and SHALL append subsequent pages through infinite scroll.
2. WHEN a list or detail screen is awaiting its first response, THE requesting screen SHALL display skeleton or shimmer placeholders.
3. THE Customer_App SHALL cache remote images so that a previously loaded image is not re-downloaded on each render.
4. WHEN the last visible list item is within three items of the end of a paginated list AND additional pages are available, THE requesting screen SHALL trigger loading of the next page.

**Backend mapping:** `GET /restaurants` and `GET /restaurants/search` (default page size 10); image URLs from `RestaurantResponse` and `MenuItemResponse`.

### Requirement 27: Responsiveness and Layout Adaptation

**User Story:** As a customer using different devices, I want the layout to adapt, so that the app is usable on phones and tablets in any orientation.

#### Acceptance Criteria

1. WHILE the Customer_App runs on a screen width below the tablet breakpoint, THE Customer_App SHALL render list content in a single-column layout.
2. WHILE the Customer_App runs on a screen width at or above the tablet breakpoint, THE Customer_App SHALL render restaurant and menu lists in a multi-column layout.
3. WHEN the device orientation changes between portrait and landscape, THE Customer_App SHALL preserve the current screen state and SHALL re-lay-out content for the new orientation.

**Backend mapping:** Not applicable (client-side presentation).

### Requirement 28: Accessibility

**User Story:** As a customer who relies on assistive technology, I want the app to be accessible, so that I can order food independently.

#### Acceptance Criteria

1. THE Customer_App SHALL provide a semantic label for every interactive control and every informational image.
2. THE Customer_App SHALL render text using scalable units that respond to the operating system text-scaling setting.
3. THE Customer_App SHALL maintain a text-to-background contrast ratio of at least 4.5 to 1 for body text in both light and dark themes.
4. THE Customer_App SHALL provide a touch target of at least 48 by 48 logical pixels for every interactive control.

**Backend mapping:** Not applicable (client-side presentation).

### Requirement 29: Theming and Design Tokens

**User Story:** As a customer, I want a consistent visual design in light and dark modes, so that the app is comfortable to use in any lighting.

#### Acceptance Criteria

1. THE Customer_App SHALL define color, typography, and spacing values as centralized design tokens consumed by all screens.
2. THE Customer_App SHALL provide a complete Material 3 light theme and a complete Material 3 dark theme derived from the design tokens.
3. WHEN the active theme mode changes, THE Customer_App SHALL apply the corresponding token set across all screens.

**Backend mapping:** Not applicable (client-side presentation).

---

## Backend Gaps & Resolution Strategy

This section consolidates every customer capability that has no existing backend endpoint. Each gap states the recommended resolution and is categorized as either a **Client-side MVP** (deliverable now with local behavior) or **Requires new backend endpoint** (cannot be fully delivered without backend work). These resolutions require user confirmation before design.

### Category A — Client-side MVP (deliverable now; server sync flagged for later)

| # | Gap | Why no endpoint | Recommended resolution | Affects |
|---|-----|-----------------|------------------------|---------|
| 3 | Payment initiation/confirmation (resolved) | No REST payment endpoint, but the payment service auto-confirms orders via Kafka | No new endpoint needed: `POST /orders` creates the order in `PENDING_PAYMENT`, the payment service auto-approves it (simulated, no real gateway) and emits `payment-completed` through the existing Kafka outbox choreography, and the order service drives the order to `CONFIRMED`. The client places the order and polls order status until it leaves `PENDING_PAYMENT` (normally `CONFIRMED`, or `FAILED` on failure). `PaymentRepository` stays swappable for a future real gateway. | Req 14, 15 |
| 4 | Saved addresses | No address endpoint exists | Persist addresses locally (secure storage / preferences); submit inline in `POST /orders` (`deliveryLocation`, `deliveryAddress`). Flag server-synced address book as a future endpoint. | Req 13, 19 |
| 5 | Favorites | No favorites endpoint exists | Persist favorited restaurant ids locally; resolve display data via `GET /restaurants/{id}`. Flag server-backed favorites as future. | Req 20 |
| 6 | Notification history | Notification service is Kafka-only with no REST fetch endpoint | Use push delivery plus a local notification store for MVP. Flag a notification-history endpoint as future. | Req 21 |
| 9 | Promotions and recommended | No promotions/recommendations endpoint exists | Derive "recommended" client-side from `GET /restaurants` ordered by rating; show promotions as curated/static client content. Flag server-driven promotions as future. | Req 9 |
| 11 | Cuisine/category catalog | `CategoryController` exposes only owner-only endpoints; no customer-facing list of cuisines/categories | Derive the filter-chip catalog client-side from loaded restaurant data while still filtering via the `category` query parameter on `GET /restaurants`. Flag a categories-list endpoint as future. | Req 7 |
| 12 | Coupon redemption | No coupon/discount endpoint exists | Present a UI-ready coupon input with no server-side discount applied. Flag coupon validation/redemption as future. | Req 12 |

### Category B — Requires new backend endpoint (cannot be fully delivered without backend work)

| # | Gap | Why no endpoint | Recommended resolution | Affects |
|---|-----|-----------------|------------------------|---------|
| 1 | Token refresh / revocation | `AuthResponse` contains a single token; no `/auth/refresh` and no refresh token | Build the Dio interceptor and auth architecture with a single 401 interception point so a refresh flow drops in later. Current behavior on 401: clear session and route to login. Recommend adding `POST /auth/refresh`. | Req 3, 4, 5 |
| 2 | Forgot password / OTP | No password-recovery or OTP endpoints exist | Present forgot-password and OTP screens as disabled "coming soon", isolated behind a repository. Recommend adding password-recovery and OTP endpoints. | Req 6 |
| 7 | Profile view/edit | No profile read/update endpoint exists | Display profile from JWT Identity_Claims; present editing as disabled behind a repository. Recommend adding `GET`/`PUT /auth/me`. | Req 18 |
| 8 | Rating/review submission | Rating is read-only on `RestaurantResponse`; no review endpoint | Display ratings only. Recommend adding a review-submission endpoint. | Req 10 |
| 10 | Live delivery-partner location | Delivery service is not routed through the gateway; no customer-facing tracking endpoint | Poll `GET /orders/{orderId}` for the status lifecycle now; obtain updates via a stream-based repository so WebSockets can be added without restructuring. Recommend adding a customer-facing live-location endpoint or stream. | Req 17 |

### Notes on real-time readiness

Requirements 17 and 21 both require a stream-based repository abstraction. This keeps the current polling implementation (Req 17.3) and push-plus-local-store implementation (Req 21) swappable for a real-time transport (for example WebSockets) without restructuring the consuming screens, addressing Gaps 6 and 10 as future enhancements rather than rewrites.
