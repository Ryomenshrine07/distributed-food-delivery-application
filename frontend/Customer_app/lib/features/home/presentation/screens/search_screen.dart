import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../home_controller.dart';

/// Search screen with debounced text input and real-time results.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(restaurantSearchControllerProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search restaurants...',
            border: InputBorder.none,
          ),
          onChanged: (value) => ref
              .read(restaurantSearchControllerProvider.notifier)
              .search(value),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(restaurantSearchControllerProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: searchState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48,
                  color: theme.colorScheme.error),
              SizedBox(height: tokens.spaceMd),
              Text('Search failed', style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
        data: (restaurants) {
          if (restaurants.isEmpty && _searchController.text.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 64,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.4)),
                  SizedBox(height: tokens.spaceMd),
                  Text('No results found',
                      style: theme.textTheme.titleMedium),
                ],
              ),
            );
          }

          if (restaurants.isEmpty) {
            return Center(
              child: Text(
                'Start typing to search',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: restaurants.length,
            padding: EdgeInsets.symmetric(vertical: tokens.spaceSm),
            itemBuilder: (context, index) {
              final r = restaurants[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.restaurant,
                      color: theme.colorScheme.onPrimaryContainer),
                ),
                title: Text(r.name),
                subtitle: r.cuisine != null ? Text(r.cuisine!) : null,
                trailing: r.rating != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 2),
                          Text(r.rating!.toStringAsFixed(1)),
                        ],
                      )
                    : null,
                onTap: () => context.push(AppRoutes.restaurantPath(r.id)),
              );
            },
          );
        },
      ),
    );
  }
}
