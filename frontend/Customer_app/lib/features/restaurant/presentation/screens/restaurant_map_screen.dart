import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../home/presentation/home_controller.dart';

import '../../../../core/location/location_providers.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantMapScreen extends ConsumerStatefulWidget {
  const RestaurantMapScreen({super.key});

  @override
  ConsumerState<RestaurantMapScreen> createState() => _RestaurantMapScreenState();
}

class _RestaurantMapScreenState extends ConsumerState<RestaurantMapScreen> {
  Restaurant? _selectedRestaurant;
  
  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(homeFeedControllerProvider).value?.restaurants ?? [];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Restaurants'),
        actions: [
          IconButton(
            icon: Icon(Icons.list, color: Theme.of(context).colorScheme.primary),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(25.4486, 78.5696), // default center (Jhansi)
              zoom: 12,
            ),
            markers: _buildMarkers(restaurants),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          if (_selectedRestaurant != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => context.push('/restaurant/${_selectedRestaurant!.id}'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _selectedRestaurant!.imageUrl != null
                            ? Image.network(
                                _selectedRestaurant!.imageUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[200],
                                child: const Icon(Icons.restaurant, color: Colors.grey),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedRestaurant!.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedRestaurant!.cuisine ?? 'Various',
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  _selectedRestaurant!.rating?.toStringAsFixed(1) ?? 'New',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(List<Restaurant> restaurants) {
    return restaurants
        .where((r) => r.latitude != null && r.longitude != null)
        .map((r) => Marker(
              markerId: MarkerId(r.id),
              position: LatLng(r.latitude!, r.longitude!),
              onTap: () => setState(() => _selectedRestaurant = r),
            ))
        .toSet();
  }
}
