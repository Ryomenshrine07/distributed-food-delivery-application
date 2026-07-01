import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/app_tokens.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../cart/presentation/widgets/cart_icon_button.dart';
import '../../home/presentation/home_controller.dart';
import '../domain/entities/restaurant.dart';

part 'restaurant_detail_screen.g.dart';

/// Fetches a single restaurant with its menu (family provider keyed by ID).
@riverpod
Future<Restaurant> restaurantDetail(Ref ref, String id) async {
  final repo = ref.watch(restaurantRepositoryProvider);
  final result = await repo.getMenu(id);
  return result.fold(
    (failure) => throw failure,
    (restaurant) => restaurant,
  );
}

/// Restaurant detail screen with collapsible header and categorized menu.
class RestaurantDetailScreen extends ConsumerWidget {
  const RestaurantDetailScreen({super.key, required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(restaurantDetailProvider(restaurantId));
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Scaffold(
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48,
                  color: theme.colorScheme.error),
              SizedBox(height: tokens.spaceMd),
              Text('Failed to load restaurant'),
              SizedBox(height: tokens.spaceMd),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(restaurantDetailProvider(restaurantId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (restaurant) => CustomScrollView(
          slivers: [
            // Collapsible header
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              actions: [
                const CartIconButton(),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(restaurant.name,
                    style: const TextStyle(shadows: [
                      Shadow(blurRadius: 8, color: Colors.black54),
                    ])),
                background: _RestaurantHeroImage(
                  imageUrl: restaurant.coverImageUrl ?? restaurant.imageUrl,
                ),
              ),
            ),

            // Restaurant info
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(tokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (restaurant.description != null)
                      Text(restaurant.description!,
                          style: theme.textTheme.bodyMedium),
                    SizedBox(height: tokens.spaceSm),
                    Wrap(
                      spacing: tokens.spaceMd,
                      children: [
                        if (restaurant.cuisine != null)
                          Chip(label: Text(restaurant.cuisine!)),
                        if (restaurant.rating != null)
                          Chip(
                            avatar: const Icon(Icons.star, size: 16),
                            label: Text(
                                restaurant.rating!.toStringAsFixed(1)),
                          ),
                        if (restaurant.averageDeliveryTime != null)
                          Chip(
                            avatar: const Icon(Icons.access_time, size: 16),
                            label: Text(
                                '${restaurant.averageDeliveryTime} min'),
                          ),
                        if (restaurant.isOpen != null)
                          Chip(
                            backgroundColor: restaurant.isOpen!
                                ? tokens.success.withValues(alpha: 0.1)
                                : theme.colorScheme.errorContainer,
                            label: Text(
                              restaurant.isOpen! ? 'Open' : 'Closed',
                              style: TextStyle(
                                color: restaurant.isOpen!
                                    ? tokens.success
                                    : theme.colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: tokens.spaceMd),
                    const Divider(),
                  ],
                ),
              ),
            ),

            // Menu categories
            if (restaurant.categories.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(tokens.spaceLg),
                  child: Center(
                    child: Text('No menu available',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ),
                ),
              )
            else
              ...restaurant.categories.map((category) => SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.spaceMd,
                            vertical: tokens.spaceSm,
                          ),
                          child: Text(category.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = category.items[index];
                            return _MenuItemTile(
                              item: item,
                              restaurantId: restaurant.id,
                              restaurantName: restaurant.name,
                            );
                          },
                          childCount: category.items.length,
                        ),
                      ),
                    ],
                  )),
          ],
        ),
      ),
    );
  }
}

class _MenuItemTile extends ConsumerWidget {
  const _MenuItemTile({
    required this.item,
    required this.restaurantId,
    required this.restaurantName,
  });
  final dynamic item;
  final String restaurantId;
  final String restaurantName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd, vertical: tokens.spaceXs),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (item.vegetarian)
                          Container(
                            margin: EdgeInsets.only(right: tokens.spaceXs),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Icon(Icons.circle,
                                color: Colors.green, size: 8),
                          ),
                        Expanded(
                          child: Text(item.name,
                              style: theme.textTheme.titleSmall),
                        ),
                      ],
                    ),
                    if (item.description != null) ...[
                      SizedBox(height: tokens.spaceXs),
                      Text(item.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                    SizedBox(height: tokens.spaceSm),
                    Text('₹${item.price}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        )),
                  ],
                ),
              ),
              SizedBox(width: tokens.spaceMd),
              Column(
                children: [
                  // Menu item image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                      child: item.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.fastfood_outlined,
                                    color: theme.colorScheme.onSurfaceVariant),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.fastfood_outlined,
                                    color: theme.colorScheme.onSurfaceVariant),
                              ),
                            )
                          : Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: Icon(Icons.fastfood_outlined,
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                    ),
                  ),
                  SizedBox(height: tokens.spaceXs),
                  if (item.available)
                    SizedBox(
                      height: 32,
                      child: FilledButton.tonal(
                        onPressed: () {
                          ref.read(cartControllerProvider.notifier).addItem(
                                restaurantId: restaurantId,
                                restaurantName: restaurantName,
                                menuItemId: item.id,
                                itemName: item.name,
                                price: item.price,
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.name} added to cart'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('ADD'),
                      ),
                    )
                  else
                    Text('Unavailable',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                        )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero image shown in the collapsible SliverAppBar.
/// Shows the restaurant's cover/image photo when available, with a
/// gradient overlay so the title text is always legible, and falls
/// back gracefully to the branded placeholder.
class _RestaurantHeroImage extends StatelessWidget {
  const _RestaurantHeroImage({this.imageUrl});
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl == null) {
      return Container(
        color: theme.colorScheme.primaryContainer,
        child: Center(
          child: Icon(Icons.restaurant, size: 64,
              color: theme.colorScheme.onPrimaryContainer
                  .withValues(alpha: 0.3)),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      // Subtle dark gradient so the white title text is readable.
      imageBuilder: (_, imageProvider) => DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black45],
          ),
        ),
      ),
      placeholder: (_, __) => Container(
        color: theme.colorScheme.primaryContainer,
        child: Center(
          child: Icon(Icons.restaurant, size: 64,
              color: theme.colorScheme.onPrimaryContainer
                  .withValues(alpha: 0.3)),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        color: theme.colorScheme.primaryContainer,
        child: Center(
          child: Icon(Icons.restaurant, size: 64,
              color: theme.colorScheme.onPrimaryContainer
                  .withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
