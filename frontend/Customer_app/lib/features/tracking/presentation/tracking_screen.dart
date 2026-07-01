import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/call_button.dart';
import '../../../core/maps/directions_service.dart';
import '../../../core/maps/marker_animator.dart';
import '../../../core/maps/marker_icon_factory.dart';
import '../../../core/websocket/tracking_socket.dart';
import '../../../core/storage/secure_storage.dart';
import '../../orders/data/dtos/order_dto.dart';
import '../../orders/data/mappers/order_mapper.dart';
import '../../orders/domain/entities/order.dart';
import '../../orders/domain/order_status.dart';

part 'tracking_screen.g.dart';

@riverpod
class OrderTrackingController extends _$OrderTrackingController {
  Timer? _timer;

  @override
  Future<Order> build(String orderId) async {
    ref.onDispose(() => _timer?.cancel());
    final order = await _fetchOrder(orderId);
    _startPolling(orderId, order);
    return order;
  }

  Future<Order> _fetchOrder(String orderId) async {
    try {
      final api = ApiClient();
      final dto = await api.getJson<OrderDto>(
        '/orders/$orderId',
        fromJsonT: (json) => OrderDto.fromJson(json as Map<String, dynamic>),
      );
      return OrderMapper.fromDto(dto);
    } on AppException {
      rethrow;
    }
  }

  void _startPolling(String orderId, Order current) {
    if (_isTerminal(current.status)) return;

    _timer = Timer.periodic(AppConstants.pollingInterval, (_) async {
      try {
        final order = await _fetchOrder(orderId);
        state = AsyncData(order);
        if (_isTerminal(order.status)) {
          _timer?.cancel();
        }
      } catch (_) {}
    });
  }

  bool _isTerminal(OrderStatus status) {
    return switch (status) {
      OrderStatus.delivered ||
      OrderStatus.cancelled ||
      OrderStatus.failed => true,
      _ => false,
    };
  }
}

@riverpod
Future<Map<String, dynamic>?> deliveryPartnerDetails(Ref ref, String? partnerId) async {
  if (partnerId == null) return null;
  try {
    final api = ApiClient();
    final data = await api.getJson<Map<String, dynamic>>(
      '/api/delivery/partners/$partnerId',
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
    return data;
  } catch (e) {
    debugPrint('Failed to fetch partner details: $e');
    return null;
  }
}

@riverpod
Future<Map<String, dynamic>?> restaurantDetails(Ref ref, String restaurantId) async {
  try {
    final api = ApiClient();
    final data = await api.getEnvelope<Map<String, dynamic>>(
      '/restaurants/$restaurantId',
      fromJsonT: (json) => json as Map<String, dynamic>,
    );
    return data;
  } catch (e) {
    debugPrint('Failed to fetch restaurant details: $e');
    return null;
  }
}

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key, required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync = ref.watch(orderTrackingControllerProvider(orderId));
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: trackingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: tokens.spaceMd),
              const Text('Failed to load order details'),
              SizedBox(height: tokens.spaceMd),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(orderTrackingControllerProvider(orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (order) => _OrderTrackingView(order: order),
      ),
    );
  }
}

class _OrderTrackingView extends ConsumerStatefulWidget {
  const _OrderTrackingView({required this.order});
  final Order order;

  @override
  ConsumerState<_OrderTrackingView> createState() => _OrderTrackingViewState();
}

class _OrderTrackingViewState extends ConsumerState<_OrderTrackingView>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late MarkerAnimator _markerAnimator;
  StreamSubscription? _locationSub;

  final MarkerIconFactory _markerIconFactory = MarkerIconFactory();
  BitmapDescriptor? _riderPuck;
  bool _puckRequested = false;

  late LatLng _customerLocation;
  late LatLng _riderLocation;
  bool _hasRiderLocation = false;

  List<LatLng> _polylinePoints = [];
  String _eta = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _customerLocation = LatLng(
        widget.order.deliveryLocation.latitude,
        widget.order.deliveryLocation.longitude,
    );
    _riderLocation = _customerLocation;
    _markerAnimator = MarkerAnimator(
      controller:
          AnimationController(vsync: this, duration: const Duration(seconds: 2))
            ..addListener(() {
              setState(() {
                _riderLocation = _markerAnimator.currentValue;
              });
            }),
      initialPosition: _riderLocation,
    );

    _initTracking();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ensureRiderPuck();
  }

  /// Builds the custom rider puck once, on the first frame, using the live
  /// device pixel ratio and the `riderMarker` token. Until it is ready (or if
  /// rendering fails) the map keeps the default rider marker (Req 1.3, 1.9).
  Future<void> _ensureRiderPuck() async {
    if (_puckRequested) return;
    _puckRequested = true;
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    try {
      final puck = await _markerIconFactory.vehiclePuck(
        color: tokens.riderMarker,
        devicePixelRatio: dpr,
      );
      if (mounted) setState(() => _riderPuck = puck);
    } catch (_) {
      // Keep the default marker on failure; never crash (Req 1.9).
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingPayment:
        return 'Waiting for payment...';
      case OrderStatus.confirmed:
        return 'Waiting for restaurant...';
      case OrderStatus.preparing:
        return 'Order is being prepared 🍳';
      case OrderStatus.readyForPickup:
        return 'Ready for pickup 🥡';
      case OrderStatus.deliveryPartnerAssigned:
        return 'Delivery partner assigned';
      case OrderStatus.outForDelivery:
        return 'Order is on the way 🤘';
      case OrderStatus.delivered:
        return 'Order delivered 🎉';
      default:
        return 'Processing your order...';
    }
  }

  bool _isDelivering = false;
  Future<void> _confirmReceived() async {
    setState(() => _isDelivering = true);
    try {
      final api = ApiClient();
      await api.postJson(
        '/orders/${widget.order.id}/receive',
        body: {},
        fromJsonT: (json) => json,
      );
      ref.invalidate(orderTrackingControllerProvider(widget.order.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to confirm receipt: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDelivering = false);
      }
    }
  }

  void _initTracking() async {
    final socket = ref.read(trackingSocketProvider);
    final tokenStore = ref.read(tokenStoreProvider);
    final token = await tokenStore.read();

    socket.connect(widget.order.id, token: token);

    // On (re-)entry the view state is fresh, so `_hasRiderLocation` is false and
    // the rider marker would stay blank until the next socket emission (which
    // can be several seconds away). If the socket still holds the last known
    // position for this order, seed the marker immediately — jumping (not
    // sliding) to that position — and redraw the route so the screen looks the
    // same as when the user left it. The live listener below keeps refining it.
    final last = socket.lastLocationFor(widget.order.id);
    if (last != null && mounted) {
      final seeded = LatLng(last.latitude, last.longitude);
      _markerAnimator.jumpTo(seeded);
      setState(() {
        _hasRiderLocation = true;
        _riderLocation = seeded;
      });
      _fetchRoute(origin: seeded);
    }

    _locationSub = socket.locationStream.listen((update) {
      if (mounted) {
        final nextLocation = LatLng(update.latitude, update.longitude);
        setState(() => _hasRiderLocation = true);
        _markerAnimator.animateTo(nextLocation);
        // Refresh route periodically or when distance changes significantly
        _fetchRoute(origin: nextLocation);
      }
    });
  }

  Future<void> _fetchRoute({LatLng? origin}) async {
    if (!_hasRiderLocation ||
        widget.order.status != OrderStatus.outForDelivery) {
      return;
    }

    final directions = ref.read(directionsServiceProvider);
    final info = await directions.getDirections(
      origin: origin ?? _riderLocation,
      destination: _customerLocation,
    );
    if (info != null && mounted) {
      setState(() {
        _polylinePoints = info.polylinePoints;
        _eta = info.totalDuration;
      });
      _fitMapToRoute();
    }
  }

  void _fitMapToRoute() {
    if (_polylinePoints.isEmpty || _mapController == null) return;
    double minLat = _polylinePoints.first.latitude;
    double maxLat = _polylinePoints.first.latitude;
    double minLng = _polylinePoints.first.longitude;
    double maxLng = _polylinePoints.first.longitude;
    for (final p in _polylinePoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80.0,
      ),
    );
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    ref.read(trackingSocketProvider).disconnect();
    _markerAnimator.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: Consumer(
            builder: (context, ref, child) {
              final restaurantAsync = ref.watch(restaurantDetailsProvider(widget.order.restaurantId));
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _customerLocation,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('customer'),
                    position: _customerLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                    infoWindow: const InfoWindow(title: 'Home'),
                  ),
                  if (_hasRiderLocation)
                    buildRiderMarker(
                      position: _riderLocation,
                      bearing: _markerAnimator.bearing,
                      puck: _riderPuck,
                      fallback: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                    ),
                  if (restaurantAsync.valueOrNull != null)
                    Marker(
                      markerId: const MarkerId('restaurant'),
                      position: LatLng(
                        (restaurantAsync.valueOrNull!['latitude'] ?? 0.0).toDouble(),
                        (restaurantAsync.valueOrNull!['longitude'] ?? 0.0).toDouble(),
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange,
                      ),
                      infoWindow: InfoWindow(
                        title: restaurantAsync.valueOrNull!['name'] ?? 'Restaurant',
                      ),
                    ),
                },
                polylines: {
                  if (widget.order.status == OrderStatus.outForDelivery &&
                      _polylinePoints.isNotEmpty)
                    Polyline(
                      polylineId: const PolylineId('route'),
                      color: Colors.blue,
                      width: 5,
                      points: _polylinePoints,
                    ),
                },
                onMapCreated: (controller) => _mapController = controller,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              );
            }
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: theme.colorScheme.onPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final restaurantAsync = ref.watch(restaurantDetailsProvider(widget.order.restaurantId));
                        return Text(
                          restaurantAsync.valueOrNull?['name'] ?? 'Loading...',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                    ),
                    IconButton(
                      icon: Icon(Icons.reply, color: theme.colorScheme.onPrimary),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getStatusText(widget.order.status),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.order.status == OrderStatus.outForDelivery &&
                        _hasRiderLocation)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Arriving in $_eta',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: widget.order.status == OrderStatus.outForDelivery
                ? 260
                : 200,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final partnerAsync = ref.watch(deliveryPartnerDetailsProvider(widget.order.deliveryPartnerId));
                      final partner = partnerAsync.valueOrNull;
                      final isAssigned = widget.order.deliveryPartnerId != null;
                      final partnerName = partner?['name'] as String?;
                      final partnerPhone = partner?['phone'] as String?;
                      final name = widget.order.deliveryPartnerName ??
                          partnerName ??
                          'Delivery Partner';
                      final phone = widget.order.deliveryPartnerPhone ??
                          partnerPhone;

                      return Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAssigned ? name : 'Assigning partner...',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  isAssigned
                                      ? (phone ?? 'Live tracking starts after pickup')
                                      : 'Will arrive shortly',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isAssigned && phone != null)
                            CallButton(
                              phoneNumber: phone,
                              color: Colors.redAccent,
                            ),
                        ],
                      );
                    },
                  ),
                  if (widget.order.status == OrderStatus.outForDelivery) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isDelivering ? null : _confirmReceived,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: const Color(0xFF2B9E49),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isDelivering
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Confirm Order Received',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
