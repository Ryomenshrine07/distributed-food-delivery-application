import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/offline_queue/offline_queue.dart';
import '../../../../core/offline_queue/pending_confirmation.dart';
import '../../domain/entities/delivery_assignment.dart';
import '../../domain/entities/delivery_status.dart';
import '../../domain/repositories/assignment_repository.dart';

class AssignmentRepositoryImpl implements AssignmentRepository {
  static const String _cacheKey = 'active_assignment';

  final ApiClient _apiClient;
  final SharedPreferences _prefs;
  final OfflineQueue _offlineQueue;

  AssignmentRepositoryImpl({
    required ApiClient apiClient,
    required SharedPreferences prefs,
    required OfflineQueue offlineQueue,
  })  : _apiClient = apiClient,
        _prefs = prefs,
        _offlineQueue = offlineQueue;

  @override
  Future<DeliveryAssignment?> getActiveAssignment() async {
    // Read from local cache
    final jsonStr = _prefs.getString(_cacheKey);
    if (jsonStr == null) return null;
    
    try {
      final assignment = DeliveryAssignment.fromJson(jsonDecode(jsonStr));
      
      // Verify with backend to ensure we don't show ghost assignments
      try {
        final res = await _apiClient.get('/orders/${assignment.orderId}');
        final status = res.data['status'];
        
        // If the order is already completed or cancelled, clear the cache
        if (status == 'DELIVERED' || status == 'CANCELLED') {
          await clearActiveAssignment();
          return null;
        }
      } catch (e) {
        // If the order was deleted (404), clear the ghost assignment
        if (e.toString().contains('404') || e.toString().contains('Not Found')) {
          await clearActiveAssignment();
          return null;
        }
        // If offline (NoConnectionFailure) or other error, we keep the cached assignment
      }
      
      return assignment;
    } catch (e) {
      debugPrint('Error parsing cached assignment: $e');
      return null;
    }
  }

  @override
  Future<void> cacheAssignment(DeliveryAssignment assignment) async {
    await _prefs.setString(_cacheKey, jsonEncode(assignment.toJson()));
  }

  @override
  Future<Result<void>> markPickedUp(String orderId) async {
    try {
      // TODO: Gap 0 — gateway routing for delivery assignments
      await _apiClient.postVoid('/api/delivery/assignments/$orderId/picked-up');

      // Update cached assignment status
      final assignment = await getActiveAssignment();
      if (assignment != null) {
        await cacheAssignment(assignment.copyWith(
          status: DeliveryStatus.pickedUp,
          pickedUpAt: DateTime.now(),
        ));
      }

      return const Right(null);
    } on NoConnectionFailure {
      // Enqueue for offline retry
      final confirmation = PendingConfirmation(
        id: 'pickup_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        type: ConfirmationType.pickedUp,
        enqueuedAt: DateTime.now(),
      );
      await _offlineQueue.enqueue(confirmation);

      // Optimistically update cache
      final assignment = await getActiveAssignment();
      if (assignment != null) {
        await cacheAssignment(assignment.copyWith(
          status: DeliveryStatus.pickedUp,
          pickedUpAt: DateTime.now(),
        ));
      }

      return const Right(null); // Queued — treated as soft success
    } catch (e) {
      if (e is Failure) return Left(e);
      // 409 Conflict is treated as success (idempotent)
      if (e.toString().contains('409')) return const Right(null);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markDelivered(String orderId) async {
    try {
      // TODO: Gap 0 — gateway routing for delivery assignments
      await _apiClient.postVoid('/api/delivery/assignments/$orderId/delivered');

      // Update cached assignment
      final assignment = await getActiveAssignment();
      if (assignment != null) {
        await cacheAssignment(assignment.copyWith(
          status: DeliveryStatus.delivered,
          deliveredAt: DateTime.now(),
        ));
      }

      return const Right(null);
    } on NoConnectionFailure {
      final confirmation = PendingConfirmation(
        id: 'delivery_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
        orderId: orderId,
        type: ConfirmationType.delivered,
        enqueuedAt: DateTime.now(),
      );
      await _offlineQueue.enqueue(confirmation);

      // Optimistically update cache
      final assignment = await getActiveAssignment();
      if (assignment != null) {
        await cacheAssignment(assignment.copyWith(
          status: DeliveryStatus.delivered,
          deliveredAt: DateTime.now(),
        ));
      }

      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      if (e.toString().contains('409')) return const Right(null);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> clearActiveAssignment() async {
    await _prefs.remove(_cacheKey);
  }

  @override
  Future<Result<List<DeliveryAssignment>>> getOffers() async {
    try {
      final response = await _apiClient.get('/api/delivery/assignments/offers');
      final data = response.data as List<dynamic>;
      
      final List<DeliveryAssignment> enrichedOffers = [];
      for (final json in data) {
         final baseAssignment = DeliveryAssignment.fromJson(json as Map<String, dynamic>);
         
         try {
             final orderRes = await _apiClient.get('/orders/${baseAssignment.orderId}');
             final orderData = orderRes.data;
             final restaurantId = orderData['restaurantId'];
             final restaurantRes = await _apiClient.get('/restaurants/$restaurantId');
             
             final restaurantData = restaurantRes.data['data']; // RestaurantResponse is wrapped in ApiResponse
             
             enrichedOffers.add(baseAssignment.copyWith(
                customerName: orderData['customerName'] ?? 'Unknown Customer',
                customerAddress: orderData['deliveryLocation']?['address'] ?? 'Unknown Address',
                customerPhone: orderData['customerPhone'],
                customerLatitude: (orderData['deliveryLocation']?['latitude'] ?? 0.0).toDouble(),
                customerLongitude: (orderData['deliveryLocation']?['longitude'] ?? 0.0).toDouble(),
                itemCount: (orderData['items'] as List?)?.length ?? 0,
                restaurantName: restaurantData['name'] ?? 'Unknown Restaurant',
                restaurantAddress: restaurantData['address'] ?? 'Unknown Address',
             ));
         } catch (e) {
             debugPrint('Failed to enrich assignment ${baseAssignment.id}: $e');
             enrichedOffers.add(baseAssignment);
         }
      }
      return Right(enrichedOffers);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> acceptOffer(String orderId) async {
    try {
      await _apiClient.postVoid('/api/delivery/assignments/$orderId/accept');
      return const Right(null);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
