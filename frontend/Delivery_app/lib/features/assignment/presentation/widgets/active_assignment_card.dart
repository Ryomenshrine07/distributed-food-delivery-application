import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/entities/delivery_assignment.dart';
import '../../domain/entities/delivery_status.dart';

/// A single prominent card summarizing the accepted, active [assignment].
///
/// Renders a status timeline (Assigned -> Picked up -> Delivered) plus the
/// next navigation action, which links into the existing
/// `assignment_detail_screen` via [onNavigate] (Req 7.11).
class ActiveAssignmentCard extends StatelessWidget {
  const ActiveAssignmentCard({
    super.key,
    required this.assignment,
    required this.onNavigate,
  });

  /// The active assignment to summarize.
  final DeliveryAssignment assignment;

  /// Invoked when the rider taps the next navigation action. The home screen
  /// wires this to push the existing assignment detail screen.
  final VoidCallback onNavigate;

  /// The label for the next navigation action, derived from the current status.
  String get _nextActionLabel {
    switch (assignment.status) {
      case DeliveryStatus.pickedUp:
        return 'Navigate to Customer';
      case DeliveryStatus.assigned:
        return 'Navigate to Restaurant';
      case DeliveryStatus.pending:
      case DeliveryStatus.delivered:
        return 'View Details';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = context.typography;
    final colors = context.colors;

    return Card(
      margin: EdgeInsets.all(tokens.space16),
      child: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, color: colors.primary),
                SizedBox(width: tokens.space8),
                Expanded(
                  child: Text('Active delivery', style: text.titleMedium),
                ),
                Text(
                  '${assignment.itemCount} '
                  'item${assignment.itemCount == 1 ? '' : 's'}',
                  style: text.labelMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.space16),
            _StatusTimeline(status: assignment.status),
            SizedBox(height: tokens.space16),
            Text(
              assignment.restaurantName,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              assignment.customerAddress,
              style: text.bodySmall?.copyWith(color: colors.onSurfaceVariant),
            ),
            SizedBox(height: tokens.space16),
            Semantics(
              button: true,
              label: _nextActionLabel,
              child: FilledButton.icon(
                onPressed: onNavigate,
                icon: const Icon(Icons.navigation),
                label: Text(_nextActionLabel),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A horizontal three-step timeline: Assigned -> Picked up -> Delivered.
///
/// Steps up to and including the current [status] are rendered as reached
/// (filled with the brand color and a check), later steps as pending.
class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final DeliveryStatus status;

  static const List<(DeliveryStatus, String)> _steps = [
    (DeliveryStatus.assigned, 'Assigned'),
    (DeliveryStatus.pickedUp, 'Picked up'),
    (DeliveryStatus.delivered, 'Delivered'),
  ];

  /// Index of the current status within [_steps]; -1 when the assignment has
  /// not reached the "Assigned" step yet (e.g. still pending).
  int get _currentIndex {
    switch (status) {
      case DeliveryStatus.assigned:
        return 0;
      case DeliveryStatus.pickedUp:
        return 1;
      case DeliveryStatus.delivered:
        return 2;
      case DeliveryStatus.pending:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.typography;
    final currentIndex = _currentIndex;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final connectorIndex = i ~/ 2;
          final isCompleted = connectorIndex < currentIndex;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                height: 3,
                color: isCompleted
                    ? colors.primary
                    : colors.outlineVariant,
              ),
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final (_, label) = _steps[stepIndex];
        final isReached = stepIndex <= currentIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isReached
                    ? colors.primary
                    : colors.surfaceContainerHighest,
              ),
              child: Center(
                child: isReached
                    ? Icon(Icons.check, size: 18, color: colors.onPrimary)
                    : Text(
                        '${stepIndex + 1}',
                        style: text.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 72,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: text.labelSmall?.copyWith(
                  color: isReached ? colors.primary : colors.onSurfaceVariant,
                  fontWeight: isReached ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
