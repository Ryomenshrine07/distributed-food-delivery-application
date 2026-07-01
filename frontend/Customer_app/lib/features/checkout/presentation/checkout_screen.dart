import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/maps/geocoding_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../orders/data/dtos/delivery_location_dto.dart';
import '../../orders/data/dtos/order_dto.dart';
import '../../orders/data/mappers/order_mapper.dart';
import '../../orders/domain/entities/order.dart';
import '../data/dtos/create_order_dto.dart';
import '../data/dtos/create_order_item_dto.dart';

part 'checkout_screen.g.dart';

/// Non-numeric resolution state of the delivery location shown at checkout.
///
/// The raw latitude/longitude are never surfaced; the UI shows only this status
/// plus the human-readable address (Requirement 4.1).
enum LocationStatus {
  /// No resolution attempt has started yet.
  idle,

  /// A GPS or geocoding resolve is in flight (Req 4.4).
  resolving,

  /// Coordinates resolved from GPS or geocoding (Req 4.5).
  resolved,

  /// Resolution failed; the customer's typed address is used instead (Req 4.6).
  failed,
}

/// Whether the checkout "Place Order" action should be enabled.
///
/// Pure function (no widget/provider dependencies) so the enablement gate is
/// unit- and property-testable per Correctness Property 5. The order can be
/// placed **iff** the customer has entered a delivery address ([hasAddress])
/// AND the delivery location has fully resolved from GPS or geocoding — both
/// [lat] and [lng] are non-null. Requiring resolved coordinates here is what
/// keeps unresolved, defaulted, or hand-typed coordinates from ever being
/// submitted.
///
/// Validates Requirements 4.7 (disabled while unresolved) and 4.8 (provenance).
bool canPlaceOrder({
  required bool hasAddress,
  required double? lat,
  required double? lng,
}) =>
    hasAddress && lat != null && lng != null;

/// The delivery coordinates submitted with an order, taken *solely* from the
/// resolved internal screen state ([lat]/[lng], set by GPS or geocoding).
///
/// Pure provenance seam for Correctness Property 5: it returns null when the
/// location has not resolved, so there is no default or hand-typed fallback.
/// When it returns a record, those values are exactly the resolved coordinates
/// — the only source the checkout ever submits (Requirement 4.8).
({double latitude, double longitude})? resolvedOrderCoordinates(
  double? lat,
  double? lng,
) {
  if (lat == null || lng == null) return null;
  return (latitude: lat, longitude: lng);
}

/// Places an order via POST /orders.
@riverpod
class CheckoutController extends _$CheckoutController {
  @override
  AsyncValue<Order?> build() => const AsyncData(null);

  /// Submits the order with the current cart, delivery address and the
  /// resolved delivery coordinates (set from GPS or by geocoding the address
  /// in the UI). The coordinates are authoritative here.
  Future<void> placeOrder({
    required String deliveryAddress,
    required double latitude,
    required double longitude,
  }) async {
    final cart = ref.read(cartControllerProvider);
    if (cart.isEmpty || cart.restaurantId == null) return;

    state = const AsyncLoading();

    try {
      final createOrderDto = CreateOrderDto(
        restaurantId: cart.restaurantId!,
        deliveryAddress: deliveryAddress,
        deliveryLocation: DeliveryLocationDto(
          address: deliveryAddress,
          latitude: latitude,
          longitude: longitude,
        ),
        items: cart.lines
            .map((line) => CreateOrderItemDto(
                  menuItemId: line.menuItemId,
                  itemName: line.itemName,
                  quantity: line.quantity,
                ))
            .toList(),
      );

      final api = ApiClient();
      final orderDto = await api.postJson<OrderDto>(
        '/orders',
        body: createOrderDto.toJson(),
        fromJsonT: (json) =>
            OrderDto.fromJson(json as Map<String, dynamic>),
      );

      final order = OrderMapper.fromDto(orderDto);

      // Clear cart after successful order placement.
      ref.read(cartControllerProvider.notifier).clearCart();

      state = AsyncData(order);
    } on AppException catch (e) {
      state = AsyncError(mapExceptionToFailure(e), StackTrace.current);
    } catch (e) {
      state = AsyncError(
        mapExceptionToFailure(UnknownException(error: e)),
        StackTrace.current,
      );
    }
  }
}

/// Checkout screen where user confirms delivery address and places order.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();

  // Resolved delivery coordinates — internal screen state only. They are set
  // from the device GPS (on open / on demand) or by geocoding the typed
  // address, and are the *sole* source of the coordinates submitted with the
  // order (Req 4.1, 4.8). They are never shown to, nor editable by, the
  // customer.
  double? _lat;
  double? _lng;

  // Non-numeric resolution status backing the location indicator (Req 4.4–4.6).
  // Starts as `idle`; the on-open post-frame GPS resolve flips it to
  // `resolving`. Both idle and resolving render the same "finding…" indicator.
  LocationStatus _status = LocationStatus.idle;

  @override
  void initState() {
    super.initState();
    // Pre-fill the delivery point with the customer's actual location so the
    // home marker lands exactly where they are (not a fuzzy geocoded address).
    WidgetsBinding.instance.addPostFrameCallback((_) => _useCurrentLocation());
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  /// Sets the delivery point to the device's current GPS location and fills the
  /// address label via reverse geocoding. Coordinates stay internal — they are
  /// never displayed or editable (Req 4.2).
  Future<void> _useCurrentLocation() async {
    if (_status == LocationStatus.resolving) return;
    setState(() => _status = LocationStatus.resolving);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Location permission denied — enter your address instead.');
        if (mounted) setState(() => _status = LocationStatus.failed);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      final address = await ref
          .read(geocodingServiceProvider)
          .reverseGeocode(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() {
        // Coordinates come straight from GPS — kept as internal state only.
        _lat = pos.latitude;
        _lng = pos.longitude;
        if (address != null && _addressController.text.trim().isEmpty) {
          _addressController.text = address;
        }
        _status = LocationStatus.resolved;
      });
    } catch (e) {
      if (mounted) setState(() => _status = LocationStatus.failed);
      _showSnack('Could not get your location.');
    }
  }

  /// Geocodes the typed address into internal delivery coordinates (use when
  /// delivering somewhere other than your current location). Coordinates stay
  /// internal — they are never displayed or editable (Req 4.3).
  Future<void> _locateTypedAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty || _status == LocationStatus.resolving) return;
    setState(() => _status = LocationStatus.resolving);
    try {
      final latLng =
          await ref.read(geocodingServiceProvider).geocode(address);
      if (!mounted) return;
      if (latLng != null) {
        setState(() {
          // Coordinates come straight from geocoding — internal state only.
          _lat = latLng.latitude;
          _lng = latLng.longitude;
          _status = LocationStatus.resolved;
        });
        _showSnack('Delivery point set from address.');
      } else {
        setState(() => _status = LocationStatus.failed);
        _showSnack('Could not find that address.');
      }
    } catch (e) {
      if (mounted) setState(() => _status = LocationStatus.failed);
      _showSnack('Could not find that address.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  /// Non-numeric delivery-location status indicator (Req 4.4–4.6). It surfaces
  /// only the resolution state and never the raw coordinates (Req 4.1).
  Widget _buildLocationStatus(ThemeData theme, AppTokens tokens) {
    switch (_status) {
      case LocationStatus.idle:
      case LocationStatus.resolving:
        return Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: Text('Finding your location…',
                  style: theme.textTheme.bodyMedium),
            ),
          ],
        );
      case LocationStatus.resolved:
        return Row(
          children: [
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: Text('Delivering to this location',
                  style: theme.textTheme.bodyMedium),
            ),
          ],
        );
      case LocationStatus.failed:
        return Row(
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.error),
            SizedBox(width: tokens.spaceSm),
            Expanded(
              child: Text(
                "Couldn't pin your exact spot — we'll use your typed address.",
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartControllerProvider);
    final checkoutState = ref.watch(checkoutControllerProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    // Navigate to tracking on successful order placement.
    ref.listen(checkoutControllerProvider, (prev, next) {
      if (next is AsyncData<Order?> && next.value != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go(AppRoutes.trackingPath(next.value!.id));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cart.isEmpty
          ? Center(
              child: Text('Your cart is empty',
                  style: theme.textTheme.bodyLarge),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(tokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Order summary
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(tokens.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order Summary',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(height: tokens.spaceSm),
                          if (cart.restaurantName != null)
                            Text('From: ${cart.restaurantName}',
                                style: theme.textTheme.bodyMedium),
                          SizedBox(height: tokens.spaceSm),
                          ...cart.lines.map((line) => Padding(
                                padding: EdgeInsets.only(
                                    bottom: tokens.spaceXs),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${line.quantity}x ${line.itemName}'),
                                    Text('₹${line.lineTotal}'),
                                  ],
                                ),
                              )),
                          const Divider(),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text('₹${cart.subtotal}',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.spaceMd),

                  // Delivery address
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(tokens.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Delivery Address',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(height: tokens.spaceSm),
                          TextField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: 'Full Address',
                              hintText: 'Enter your delivery address',
                              prefixIcon:
                                  const Icon(Icons.location_on_outlined),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                tooltip: 'Set delivery point from this address',
                                onPressed:
                                    _status == LocationStatus.resolving
                                        ? null
                                        : _locateTypedAddress,
                              ),
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(height: tokens.spaceSm),
                          OutlinedButton.icon(
                            onPressed: _status == LocationStatus.resolving
                                ? null
                                : _useCurrentLocation,
                            icon: _status == LocationStatus.resolving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.my_location),
                            label: const Text('Use my current location'),
                          ),
                          SizedBox(height: tokens.spaceSm),
                          // Non-numeric delivery-location status. The resolved
                          // latitude/longitude are internal state and are never
                          // displayed or made editable (Req 4.1).
                          _buildLocationStatus(theme, tokens),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.spaceMd),

                  // Error display
                  if (checkoutState is AsyncError)
                    Container(
                      padding: EdgeInsets.all(tokens.spaceMd),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius:
                            BorderRadius.circular(tokens.radiusSm),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: theme.colorScheme.error),
                          SizedBox(width: tokens.spaceSm),
                          Expanded(
                            child: Text(
                              'Failed to place order. Please try again.',
                              style: TextStyle(
                                  color:
                                      theme.colorScheme.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: tokens.spaceLg),

                  // Place order button — enabled only when an address and a
                  // resolved delivery location exist; it submits the resolved
                  // GPS/geocoding coordinates and nothing else (Req 4.7, 4.8).
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _addressController,
                    builder: (context, addressValue, child) {
                      final isLoading = checkoutState is AsyncLoading;
                      final enabled = canPlaceOrder(
                        hasAddress: addressValue.text.trim().isNotEmpty,
                        lat: _lat,
                        lng: _lng,
                      );
                      return FilledButton(
                        onPressed: (!enabled || isLoading)
                            ? null
                            : () {
                                // Coordinates are taken solely from the resolved
                                // internal state (_lat!/_lng!): no parsing and no
                                // default fallback (Req 4.8).
                                final coords =
                                    resolvedOrderCoordinates(_lat, _lng);
                                if (coords == null) return;
                                ref
                                    .read(checkoutControllerProvider.notifier)
                                    .placeOrder(
                                      deliveryAddress: addressValue.text.trim(),
                                      latitude: coords.latitude,
                                      longitude: coords.longitude,
                                    );
                              },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Place Order'),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
