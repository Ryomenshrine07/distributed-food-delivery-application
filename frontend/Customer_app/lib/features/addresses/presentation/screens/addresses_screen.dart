import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../addresses_controller.dart';

/// Screen for managing saved delivery addresses.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addresses = ref.watch(addressesControllerProvider);
    final theme = Theme.of(context);
    final tokens = theme.extension<AppTokens>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
      ),
      body: addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Text('No saved addresses', style: theme.textTheme.titleMedium),
                  SizedBox(height: tokens.spaceSm),
                  Text('Add an address to make checkout faster',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(tokens.spaceMd),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Card(
                  margin: EdgeInsets.only(bottom: tokens.spaceSm),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        _getIconForLabel(address.label),
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(address.label, style: theme.textTheme.titleMedium),
                    subtitle: Text(address.address),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        ref
                            .read(addressesControllerProvider.notifier)
                            .removeAddress(address.id);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('home')) return Icons.home;
    if (lower.contains('work') || lower.contains('office')) return Icons.work;
    return Icons.location_on;
  }

  void _showAddAddressDialog(BuildContext context, WidgetRef ref) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(
                labelText: 'Label (e.g. Home, Work)',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Full Address',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (labelController.text.isNotEmpty && addressController.text.isNotEmpty) {
                ref.read(addressesControllerProvider.notifier).saveAddress(
                      SavedAddress(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        label: labelController.text,
                        address: addressController.text,
                        latitude: 25.4486, // Mock coordinates (Jhansi)
                        longitude: 78.5696,
                      ),
                    );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
