import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesControllerProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_outline,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Text('No favorites yet', style: theme.textTheme.titleMedium),
                  SizedBox(height: tokens.spaceSm),
                  Text('Save your favorite restaurants here',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(tokens.spaceMd),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final restaurant = favorites[index];
                return Card(
                  margin: EdgeInsets.only(bottom: tokens.spaceSm),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push(AppRoutes.restaurantPath(restaurant.id)),
                    child: Padding(
                      padding: EdgeInsets.all(tokens.spaceMd),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                            ),
                            child: Icon(Icons.restaurant, color: theme.colorScheme.onPrimaryContainer),
                          ),
                          SizedBox(width: tokens.spaceMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(restaurant.name, style: theme.textTheme.titleMedium),
                                if (restaurant.cuisine != null)
                                  Text(restaurant.cuisine!, style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  )),
                                SizedBox(height: tokens.spaceXs),
                                Row(
                                  children: [
                                    if (restaurant.rating != null) ...[
                                      Icon(Icons.star, size: 16, color: theme.colorScheme.primary),
                                      const SizedBox(width: 2),
                                      Text(restaurant.rating!.toStringAsFixed(1), style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () {
                              ref.read(favoritesControllerProvider.notifier).toggleFavorite(restaurant);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
