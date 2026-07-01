import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../cart_controller.dart';

/// Cart review screen showing all items, quantities, subtotal, and
/// checkout navigation.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearCartDialog(context, ref),
              tooltip: 'Clear cart',
            ),
        ],
      ),
      body: cart.isEmpty
          ? _buildEmptyCart(context, tokens)
          : _buildCartContent(context, ref, cart, tokens),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal',
                            style: theme.textTheme.titleMedium),
                        Text('₹${cart.subtotal}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                    SizedBox(height: tokens.spaceSm),
                    Text(
                      'Delivery fee and taxes will be calculated at checkout',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: tokens.spaceMd),
                    FilledButton(
                      onPressed: () => context.push(AppRoutes.checkout),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                          'Proceed to Checkout (${cart.totalItems} items)'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context, AppTokens tokens) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          SizedBox(height: tokens.spaceLg),
          Text('Your cart is empty',
              style: theme.textTheme.titleLarge),
          SizedBox(height: tokens.spaceSm),
          Text('Add items from a restaurant to get started',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          SizedBox(height: tokens.spaceLg),
          FilledButton.tonal(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Browse Restaurants'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    WidgetRef ref,
    dynamic cart,
    AppTokens tokens,
  ) {
    final theme = Theme.of(context);
    return ListView(
      padding: EdgeInsets.all(tokens.spaceMd),
      children: [
        // Restaurant name
        if (cart.restaurantName != null)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spaceMd),
            child: Row(
              children: [
                Icon(Icons.restaurant,
                    size: 20, color: theme.colorScheme.primary),
                SizedBox(width: tokens.spaceSm),
                Text(cart.restaurantName!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ),

        // Cart items
        ...cart.lines.map<Widget>((line) => Card(
              margin: EdgeInsets.only(bottom: tokens.spaceSm),
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line.itemName,
                              style: theme.textTheme.titleSmall),
                          SizedBox(height: tokens.spaceXs),
                          Text('₹${line.price}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                        ],
                      ),
                    ),
                    // Quantity stepper
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: theme.colorScheme.outlineVariant),
                        borderRadius:
                            BorderRadius.circular(tokens.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () => ref
                                .read(cartControllerProvider.notifier)
                                .setQuantity(
                                    line.menuItemId, line.quantity - 1),
                            visualDensity: VisualDensity.compact,
                          ),
                          Text('${line.quantity}',
                              style: theme.textTheme.titleSmall),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => ref
                                .read(cartControllerProvider.notifier)
                                .setQuantity(
                                    line.menuItemId, line.quantity + 1),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: tokens.spaceMd),
                    Text('₹${line.lineTotal}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(cartControllerProvider.notifier).clearCart();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
