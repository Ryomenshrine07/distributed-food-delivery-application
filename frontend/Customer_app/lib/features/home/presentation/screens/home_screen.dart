import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../home_controller.dart';

/// Home screen with recommended section and paginated restaurant list.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(homeFeedControllerProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push(AppRoutes.search),
            tooltip: 'Search restaurants',
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push(AppRoutes.cart),
            tooltip: 'Cart',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notifications),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: feedAsync.when(
        loading: () => _buildShimmer(context),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48,
                  color: theme.colorScheme.error),
              SizedBox(height: tokens.spaceMd),
              Text('Failed to load restaurants',
                  style: theme.textTheme.bodyLarge),
              SizedBox(height: tokens.spaceMd),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(homeFeedControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (feedState) {
          if (feedState.restaurants.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_outlined, size: 64,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4)),
                  SizedBox(height: tokens.spaceMd),
                  Text('No restaurants found',
                      style: theme.textTheme.titleMedium),
                  SizedBox(height: tokens.spaceSm),
                  Text('Try adjusting your filters',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(homeFeedControllerProvider),
            child: CustomScrollView(
              slivers: [
                // Recommended section
                if (feedState.recommended.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(tokens.spaceMd),
                      child: Text('Recommended',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                            horizontal: tokens.spaceMd),
                        itemCount: feedState.recommended.length,
                        itemBuilder: (context, index) {
                          final r = feedState.recommended[index];
                          return _RecommendedCard(
                            restaurant: r,
                            onTap: () => context.push(
                                AppRoutes.restaurantPath(r.id)),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // All restaurants header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spaceMd),
                    child: Text('All Restaurants',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),

                // Restaurant list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == feedState.restaurants.length) {
                        // Loading more indicator
                        return feedState.isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                    child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }

                      final restaurant = feedState.restaurants[index];

                      // Trigger prefetch near end.
                      if (index == feedState.restaurants.length - 3 &&
                          !feedState.isLastPage) {
                        ref
                            .read(homeFeedControllerProvider.notifier)
                            .loadNextPage();
                      }

                      return _RestaurantListTile(
                        restaurant: restaurant,
                        onTap: () => context.push(
                            AppRoutes.restaurantPath(restaurant.id)),
                      );
                    },
                    childCount: feedState.restaurants.length + 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.restaurant, required this.onTap});
  final dynamic restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: tokens.spaceSm),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant cover image
              SizedBox(
                height: 100,
                width: double.infinity,
                child: restaurant.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: restaurant.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: theme.colorScheme.primaryContainer,
                          child: Center(
                            child: Icon(Icons.restaurant,
                                color: theme.colorScheme.onPrimaryContainer),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: theme.colorScheme.primaryContainer,
                          child: Center(
                            child: Icon(Icons.restaurant,
                                color: theme.colorScheme.onPrimaryContainer),
                          ),
                        ),
                      )
                    : Container(
                        color: theme.colorScheme.primaryContainer,
                        child: Center(
                          child: Icon(Icons.restaurant,
                              color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(tokens.spaceSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (restaurant.cuisine != null)
                      Text(
                        restaurant.cuisine!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (restaurant.rating != null)
                      Row(
                        children: [
                          Icon(Icons.star, size: 14,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 2),
                          Text(
                            restaurant.rating!.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestaurantListTile extends StatelessWidget {
  const _RestaurantListTile({required this.restaurant, required this.onTap});
  final dynamic restaurant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: tokens.spaceMd, vertical: tokens.spaceXs),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(tokens.spaceMd),
            child: Row(
              children: [
                // Restaurant thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: restaurant.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: restaurant.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(Icons.restaurant,
                                  color:
                                      theme.colorScheme.onPrimaryContainer),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: theme.colorScheme.primaryContainer,
                              child: Icon(Icons.restaurant,
                                  color:
                                      theme.colorScheme.onPrimaryContainer),
                            ),
                          )
                        : Container(
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(Icons.restaurant,
                                color: theme.colorScheme.onPrimaryContainer),
                          ),
                  ),
                ),
                SizedBox(width: tokens.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(restaurant.name,
                          style: theme.textTheme.titleMedium),
                      if (restaurant.cuisine != null)
                        Text(restaurant.cuisine!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )),
                      SizedBox(height: tokens.spaceXs),
                      Row(
                        children: [
                          if (restaurant.rating != null) ...[
                            Icon(Icons.star, size: 16,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 2),
                            Text(restaurant.rating!.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                            SizedBox(width: tokens.spaceSm),
                          ],
                          if (restaurant.averageDeliveryTime != null) ...[
                            Icon(Icons.access_time, size: 14,
                                color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text('${restaurant.averageDeliveryTime} min',
                                style: theme.textTheme.bodySmall),
                          ],
                          const Spacer(),
                          if (restaurant.isOpen != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: restaurant.isOpen!
                                    ? tokens.success.withValues(alpha: 0.1)
                                    : theme.colorScheme.errorContainer,
                                borderRadius:
                                    BorderRadius.circular(tokens.radiusPill),
                              ),
                              child: Text(
                                restaurant.isOpen! ? 'Open' : 'Closed',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: restaurant.isOpen!
                                      ? tokens.success
                                      : theme.colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
