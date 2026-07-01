import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../domain/entities/delivery_assignment.dart';
import '../../domain/entities/delivery_status.dart';
import '../providers/assignment_providers.dart';

class AssignmentDetailScreen extends ConsumerWidget {
  final String orderId;
  const AssignmentDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentState = ref.watch(assignmentControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Assignment'),
        centerTitle: true,
      ),
      body: assignmentState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Error: $e', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(assignmentControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (assignment) {
          if (assignment == null) {
            return const Center(
              child: Text('No active assignment'),
            );
          }
          return _AssignmentDetailBody(assignment: assignment);
        },
      ),
    );
  }
}

class _AssignmentDetailBody extends ConsumerWidget {
  final DeliveryAssignment assignment;
  const _AssignmentDetailBody({required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status progress indicator
          _StatusProgressBar(status: assignment.status),
          const SizedBox(height: 24),

          // Restaurant card
          _InfoCard(
            icon: Icons.restaurant,
            iconColor: Colors.orange,
            title: 'Restaurant',
            name: assignment.restaurantName,
            address: assignment.restaurantAddress,
          ),
          const SizedBox(height: 12),

          // Customer card
          _InfoCard(
            icon: Icons.person,
            iconColor: colorScheme.primary,
            title: 'Customer',
            name: assignment.customerName,
            address: assignment.customerAddress,
            phone: assignment.customerPhone,
          ),
          const SizedBox(height: 12),

          // Order info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.shopping_bag, color: colorScheme.secondary),
                  const SizedBox(width: 12),
                  Text(
                    '${assignment.itemCount} item${assignment.itemCount > 1 ? 's' : ''}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const Spacer(),
                  _StatusBadge(status: assignment.status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons based on status
          ..._buildActionButtons(context, ref, assignment),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    DeliveryAssignment assignment,
  ) {
    final isLoading = ref.watch(assignmentControllerProvider).isLoading;

    switch (assignment.status) {
      case DeliveryStatus.pending:
        return [
          const Center(child: Text('This assignment is pending acceptance.')),
        ];
      case DeliveryStatus.assigned:
        return [
          FilledButton.icon(
            onPressed: isLoading
                ? null
                : () => context.push(
                      AppRoutes.navigate(assignment.orderId, 'restaurant'),
                    ),
            icon: const Icon(Icons.navigation),
            label: const Text('Navigate to Restaurant'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () async {
                    final error = await ref
                        .read(assignmentControllerProvider.notifier)
                        .confirmPickup();
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  },
            icon: const Icon(Icons.check_circle_outline),
            label: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Confirm Pickup'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ];

      case DeliveryStatus.pickedUp:
        return [
          FilledButton.icon(
            onPressed: isLoading
                ? null
                : () => context.push(
                      AppRoutes.navigate(assignment.orderId, 'customer'),
                    ),
            icon: const Icon(Icons.navigation),
            label: const Text('Navigate to Customer'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: isLoading
                ? null
                : () async {
                    final error = await ref
                        .read(assignmentControllerProvider.notifier)
                        .confirmDelivery();
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    }
                  },
            icon: const Icon(Icons.check_circle),
            label: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Confirm Delivery'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: Colors.green,
            ),
          ),
        ];

      case DeliveryStatus.delivered:
        return [
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 12),
                  Text(
                    'Delivery Complete!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              await ref
                  .read(assignmentControllerProvider.notifier)
                  .clearAssignment();
              if (context.mounted) {
                context.go(AppRoutes.home);
              }
            },
            child: const Text('Back to Home'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
        ];
    }
  }
}

class _StatusProgressBar extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusProgressBar({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = DeliveryStatus.values;
    final currentIndex = steps.indexOf(status);
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = i ~/ 2;
          final isCompleted = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isCompleted ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          );
        } else {
          // Step circle
          final stepIndex = i ~/ 2;
          final isActive = stepIndex <= currentIndex;
          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? colorScheme.primary : colorScheme.surfaceContainerHighest,
            ),
            child: Center(
              child: isActive
                  ? Icon(Icons.check, size: 18, color: colorScheme.onPrimary)
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                    ),
            ),
          );
        }
      }),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String name;
  final String address;
  final String? phone;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.name,
    required this.address,
    this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withValues(alpha: 0.15),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  )),
                  const SizedBox(height: 4),
                  Text(name, style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 4),
                  Text(address, style: theme.textTheme.bodySmall),
                  if (phone != null) ...[
                    const SizedBox(height: 4),
                    Text(phone!, style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DeliveryStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (status) {
      DeliveryStatus.pending => (Colors.grey.shade100, Colors.grey.shade800),
      DeliveryStatus.assigned => (Colors.blue.shade100, Colors.blue.shade800),
      DeliveryStatus.pickedUp => (Colors.orange.shade100, Colors.orange.shade800),
      DeliveryStatus.delivered => (Colors.green.shade100, Colors.green.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
