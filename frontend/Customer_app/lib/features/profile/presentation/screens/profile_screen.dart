import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../authentication/presentation/auth_controller.dart';
import '../profile_controller.dart';

/// Profile screen displaying user info and navigation links to other features.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final claims = ref.watch(profileClaimsProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    if (claims == null) {
      return const Scaffold(
        body: Center(child: Text('No active session')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(tokens.spaceLg),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      claims.name.isNotEmpty ? claims.name[0].toUpperCase() : '?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  SizedBox(width: tokens.spaceMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(claims.name, style: theme.textTheme.titleLarge),
                        SizedBox(height: tokens.spaceXs),
                        Text(claims.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            )),
                        if (claims.phone != null) ...[
                          SizedBox(height: tokens.spaceXs),
                          Text(claims.phone!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: tokens.spaceMd),
            
            // Menu Items
            _ProfileMenuTile(
              icon: Icons.receipt_long_outlined,
              title: 'My Orders',
              onTap: () => context.push(AppRoutes.orders),
            ),
            _ProfileMenuTile(
              icon: Icons.favorite_outline,
              title: 'Favorites',
              onTap: () => context.push(AppRoutes.favorites),
            ),
            _ProfileMenuTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses',
              onTap: () => context.push(AppRoutes.addresses),
            ),
            _ProfileMenuTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () => context.push(AppRoutes.notifications),
            ),
            const Divider(),
            _ProfileMenuTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.push(AppRoutes.settings),
            ),
            _ProfileMenuTile(
              icon: Icons.logout,
              title: 'Sign Out',
              textColor: theme.colorScheme.error,
              iconColor: theme.colorScheme.error,
              onTap: () => _showLogoutDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authControllerProvider.notifier).logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;
    
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: textColor,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: 20, color: theme.colorScheme.onSurfaceVariant),
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.spaceLg,
        vertical: tokens.spaceXs,
      ),
      onTap: onTap,
    );
  }
}
