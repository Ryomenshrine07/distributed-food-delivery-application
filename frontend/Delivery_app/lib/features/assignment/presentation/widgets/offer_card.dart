import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/entities/delivery_assignment.dart';

/// A polished card representing a single pending delivery [offer] on the
/// delivery home.
///
/// Shows the restaurant name + pickup address, the customer + drop address, and
/// an item-count chip. Exposes two actions: a primary/brand **Accept** and a
/// secondary **Dismiss**. While [isAccepting] is true the Accept action shows
/// inline progress and both actions are disabled so the accept flow can't be
/// double-triggered (Req 7.3, 7.5, 7.6, 7.7, 9.1, 9.2).
class OfferCard extends StatelessWidget {
  const OfferCard({
    super.key,
    required this.offer,
    required this.onAccept,
    required this.onDismiss,
    this.isAccepting = false,
  });

  /// The offer to render.
  final DeliveryAssignment offer;

  /// Invoked when the rider taps **Accept**.
  final VoidCallback onAccept;

  /// Invoked when the rider taps **Dismiss**.
  final VoidCallback onDismiss;

  /// Whether an accept is currently in progress for this offer.
  final bool isAccepting;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = context.typography;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: tokens.space16,
        vertical: tokens.space8,
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('New delivery offer', style: text.titleMedium),
                ),
                _ItemCountChip(itemCount: offer.itemCount),
              ],
            ),
            SizedBox(height: tokens.space16),
            _LocationRow(
              icon: Icons.restaurant,
              iconColor: tokens.restaurantMarker,
              label: 'Pickup',
              name: offer.restaurantName,
              address: offer.restaurantAddress,
            ),
            SizedBox(height: tokens.space12),
            _LocationRow(
              icon: Icons.person_pin_circle,
              iconColor: tokens.customerMarker,
              label: 'Drop',
              name: offer.customerName,
              address: offer.customerAddress,
            ),
            SizedBox(height: tokens.space16),
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Dismiss offer',
                    child: OutlinedButton(
                      onPressed: isAccepting ? null : onDismiss,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Dismiss'),
                    ),
                  ),
                ),
                SizedBox(width: tokens.space12),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: 'Accept offer',
                    child: FilledButton(
                      onPressed: isAccepting ? null : onAccept,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: isAccepting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Accept'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A compact chip showing the number of items in the offer.
class _ItemCountChip extends StatelessWidget {
  const _ItemCountChip({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = '$itemCount item${itemCount == 1 ? '' : 's'}';
    return Chip(
      avatar: Icon(
        Icons.shopping_bag_outlined,
        size: 18,
        color: colors.onSecondaryContainer,
      ),
      label: Text(label),
      backgroundColor: colors.secondaryContainer,
      labelStyle: context.typography.labelMedium?.copyWith(
        color: colors.onSecondaryContainer,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// A single pickup/drop row: a tinted leading icon, a small label, the place
/// name, and the address beneath it.
class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.name,
    required this.address,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String name;
  final String address;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final text = context.typography;
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        SizedBox(width: tokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: text.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(address, style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
