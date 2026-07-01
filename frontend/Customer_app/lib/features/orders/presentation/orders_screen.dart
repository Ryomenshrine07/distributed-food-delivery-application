import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../core/network/api_client.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_tokens.dart';
import '../data/dtos/order_dto.dart';
import '../data/mappers/order_mapper.dart';
import '../domain/entities/order.dart';
import '../domain/order_status.dart';
import 'order_status_extension.dart';

part 'orders_screen.g.dart';

/// Fetches the list of orders for the current user.
@riverpod
Future<List<Order>> myOrders(Ref ref) async {
  try {
    final api = ApiClient();
    final dtos = await api.getJson<List<OrderDto>>(
      '/orders/my-orders',
      fromJsonT: (json) => (json as List<dynamic>)
          .map((item) => OrderDto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
    return dtos.map(OrderMapper.fromDto).toList();
  } on AppException catch (e) {
    throw mapExceptionToFailure(e);
  } catch (e) {
    throw mapExceptionToFailure(UnknownException(error: e));
  }
}

/// Orders history screen with active and past order tabs.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48,
                    color: theme.colorScheme.error),
                SizedBox(height: tokens.spaceMd),
                Text('Failed to load orders'),
                SizedBox(height: tokens.spaceMd),
                FilledButton.tonal(
                  onPressed: () => ref.invalidate(myOrdersProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (orders) {
            final active = orders
                .where((o) => _isActiveStatus(o.status))
                .toList();
            final past = orders
                .where((o) => !_isActiveStatus(o.status))
                .toList();

            return TabBarView(
              children: [
                _OrderList(orders: active, emptyMessage: 'No active orders'),
                _OrderList(orders: past, emptyMessage: 'No past orders'),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isActiveStatus(OrderStatus status) {
    return switch (status) {
      OrderStatus.pendingPayment ||
      OrderStatus.confirmed ||
      OrderStatus.preparing ||
      OrderStatus.readyForPickup ||
      OrderStatus.deliveryPartnerAssigned ||
      OrderStatus.outForDelivery =>
        true,
      _ => false,
    };
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({required this.orders, required this.emptyMessage});
  final List<Order> orders;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64,
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.4)),
            SizedBox(height: tokens.spaceMd),
            Text(emptyMessage, style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: EdgeInsets.all(tokens.spaceMd),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spaceMd),
      child: InkWell(
        onTap: () => context.push(AppRoutes.trackingPath(order.id)),
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order #${order.id.substring(0, 8)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                  _OrderStatusChip(status: order.status),
                ],
              ),
              SizedBox(height: tokens.spaceSm),
              Text('${order.items.length} items',
                  style: theme.textTheme.bodySmall),
              SizedBox(height: tokens.spaceXs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(order.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text('₹${order.totalAmount}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _OrderStatusChip extends StatelessWidget {
  const _OrderStatusChip({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final color = status.color(tokens);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Text(
        _statusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus status) => switch (status) {
        OrderStatus.pendingPayment => 'Pending',
        OrderStatus.confirmed => 'Confirmed',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.readyForPickup => 'Ready',
        OrderStatus.deliveryPartnerAssigned => 'Assigned',
        OrderStatus.outForDelivery => 'On the Way',
        OrderStatus.delivered => 'Delivered',
        OrderStatus.cancelled => 'Cancelled',
        OrderStatus.failed => 'Failed',
        OrderStatus.unknown => 'Unknown',
      };
}
