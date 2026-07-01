import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../assignment/presentation/providers/assignment_providers.dart';
import '../providers/navigation_providers.dart';
import '../../../../core/maps/directions_service.dart';
import '../../../../core/maps/marker_animator.dart';
import '../../../../core/maps/marker_icon_factory.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/call_button.dart';
import '../../../location/presentation/providers/location_providers.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String destination;

  const NavigationScreen({
    super.key,
    required this.orderId,
    required this.destination,
  });

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  late MarkerAnimator _markerAnimator;
  StreamSubscription<Position>? _positionSub;

  final MarkerIconFactory _markerIconFactory = MarkerIconFactory();
  BitmapDescriptor? _riderPuck;
  bool _puckRequested = false;

  LatLng? _driverLocation;
  List<LatLng> _polylinePoints = [];
  String _eta = 'Calculating...';

  @override
  void initState() {
    super.initState();
    // Default fallback position
    _driverLocation = const LatLng(12.9863, 77.7349); 

    _markerAnimator = MarkerAnimator(
      controller: AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      )..addListener(() {
          setState(() {
            _driverLocation = _markerAnimator.currentValue;
          });
        }),
      initialPosition: _driverLocation!,
    );

    _initLocationTracking();
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

  void _initLocationTracking() async {
    // Request permission (don't just check) — on a real device the foreground
    // service may not have prompted yet, and without this the route never loads
    // and no location is published to the customer.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    try {
      final initialPosition = await Geolocator.getCurrentPosition();
      _driverLocation =
          LatLng(initialPosition.latitude, initialPosition.longitude);
      _markerAnimator.animateTo(_driverLocation!);
      _publishHeartbeat(initialPosition);
      _fetchRoute();
    } catch (_) {
      // ignore — stream below will keep trying
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high, distanceFilter: 10),
    ).listen((position) {
      // Publish the live location to the backend so the customer's tracking
      // screen shows the rider moving (delivery-service resolves the active
      // order and the tracking-service broadcasts it over STOMP).
      _publishHeartbeat(position);
      if (mounted) {
        _markerAnimator.animateTo(LatLng(position.latitude, position.longitude));
        _fetchRoute();
      }
    });
  }

  void _publishHeartbeat(Position position) {
    // Fire-and-forget; submitHeartbeat validates the session/coords internally.
    ref
        .read(locationRepositoryProvider)
        .submitHeartbeat(position.latitude, position.longitude);
  }

  Future<void> _fetchRoute() async {
    final assignment = ref.read(assignmentControllerProvider).value;
    if (assignment == null) return;
    
    final isToRestaurant = widget.destination == 'restaurant';
    final destLat = isToRestaurant ? assignment.restaurantLatitude : assignment.customerLatitude;
    final destLng = isToRestaurant ? assignment.restaurantLongitude : assignment.customerLongitude;

    final directions = ref.read(directionsServiceProvider);
    final info = await directions.getDirections(
      origin: _driverLocation!,
      destination: LatLng(destLat, destLng),
    );

    if (info != null && mounted) {
      setState(() {
        _polylinePoints = info.polylinePoints;
        _eta = info.totalDuration;
      });
      _fitMapToRoute(destLat, destLng);
    }
  }

  void _fitMapToRoute(double destLat, double destLng) {
    if (_polylinePoints.isEmpty || _mapController == null) return;
    double minLat = _driverLocation!.latitude;
    double maxLat = _driverLocation!.latitude;
    double minLng = _driverLocation!.longitude;
    double maxLng = _driverLocation!.longitude;

    if (destLat < minLat) minLat = destLat;
    if (destLat > maxLat) maxLat = destLat;
    if (destLng < minLng) minLng = destLng;
    if (destLng > maxLng) maxLng = destLng;

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
    _positionSub?.cancel();
    _markerAnimator.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assignment = ref.watch(assignmentControllerProvider).value;

    if (assignment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigation')),
        body: const Center(child: Text('No active assignment')),
      );
    }

    final isToRestaurant = widget.destination == 'restaurant';
    final destName = isToRestaurant ? assignment.restaurantName : assignment.customerName;
    final destLat = isToRestaurant ? assignment.restaurantLatitude : assignment.customerLatitude;
    final destLng = isToRestaurant ? assignment.restaurantLongitude : assignment.customerLongitude;

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Full Screen Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(destLat, destLng),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('destination'),
                  position: LatLng(destLat, destLng),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    isToRestaurant ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueRed,
                  ),
                  infoWindow: InfoWindow(title: destName),
                ),
                buildRiderMarker(
                  position: _driverLocation!,
                  bearing: _markerAnimator.bearing,
                  puck: _riderPuck,
                  fallback: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                  infoWindowTitle: 'You',
                ),
              },
              polylines: {
                if (_polylinePoints.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('route'),
                    color: Colors.blue,
                    width: 5,
                    points: _polylinePoints,
                  ),
              },
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),

          // 2. Custom App Bar / Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
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
                      Text(
                        isToRestaurant ? 'To Restaurant' : 'To Customer',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.navigation,
                            color: theme.colorScheme.onPrimary),
                        onPressed: () {
                           ref.read(navigationControllerProvider(widget.orderId, widget.destination).notifier)
                              .launchExternalNavigation();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Deliver safely 🤘',
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // 3. Draggable Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 140, 
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
                    // Destination Details
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                          child: Icon(
                            isToRestaurant ? Icons.restaurant : Icons.person,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                destName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order #${widget.orderId}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        CallButton(
                          phoneNumber: assignment.customerPhone,
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
