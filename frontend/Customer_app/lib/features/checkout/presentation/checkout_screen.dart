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
  // Delivery coordinates — the source of truth for where the order is sent.
  // Auto-filled from the device's GPS on open (your real location); you can
  // refresh from GPS, geocode the typed address, or edit them manually.
  final _latController = TextEditingController(text: '25.4486');
  final _lngController = TextEditingController(text: '78.5696');

  bool _locating = false;

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
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  /// Sets the delivery point to the device's current GPS location and fills the
  /// address label via reverse geocoding.
  Future<void> _useCurrentLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showSnack('Location permission denied — enter your address instead.');
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      _latController.text = pos.latitude.toStringAsFixed(6);
      _lngController.text = pos.longitude.toStringAsFixed(6);
      final address = await ref
          .read(geocodingServiceProvider)
          .reverseGeocode(pos.latitude, pos.longitude);
      if (address != null && mounted && _addressController.text.trim().isEmpty) {
        _addressController.text = address;
      }
    } catch (e) {
      _showSnack('Could not get your location.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  /// Geocodes the typed address into delivery coordinates (use when delivering
  /// somewhere other than your current location).
  Future<void> _locateTypedAddress() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) return;
    setState(() => _locating = true);
    try {
      final latLng =
          await ref.read(geocodingServiceProvider).geocode(address);
      if (latLng != null) {
        _latController.text = latLng.latitude.toStringAsFixed(6);
        _lngController.text = latLng.longitude.toStringAsFixed(6);
        _showSnack('Delivery point set from address.');
      } else {
        _showSnack('Could not find that address.');
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
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
                                    _locating ? null : _locateTypedAddress,
                              ),
                            ),
                            maxLines: 2,
                          ),
                          SizedBox(height: tokens.spaceSm),
                          OutlinedButton.icon(
                            onPressed:
                                _locating ? null : _useCurrentLocation,
                            icon: _locating
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _latController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true, signed: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Latitude',
                                    prefixIcon: Icon(Icons.my_location),
                                  ),
                                ),
                              ),
                              SizedBox(width: tokens.spaceSm),
                              Expanded(
                                child: TextField(
                                  controller: _lngController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true, signed: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Longitude',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: tokens.spaceXs),
                          Text(
                            'Tip: tap "Use my current location" to drop the pin '
                            'exactly where you are, or type an address and tap '
                            'the search icon.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
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

                  // Place order button
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _addressController,
                    builder: (context, addressValue, child) {
                      return FilledButton(
                        onPressed: checkoutState is AsyncLoading ||
                                addressValue.text.trim().isEmpty
                            ? null
                            : () => ref
                                .read(checkoutControllerProvider.notifier)
                                .placeOrder(
                                  deliveryAddress:
                                      addressValue.text.trim(),
                                  latitude: double.tryParse(
                                          _latController.text) ??
                                      25.4486,
                                  longitude: double.tryParse(
                                          _lngController.text) ??
                                      78.5696,
                                ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: checkoutState is AsyncLoading
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
