import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/availability_controller.dart';

class AvailabilityToggle extends ConsumerWidget {
  const AvailabilityToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilityState = ref.watch(availabilityControllerProvider);
    final isOnline = availabilityState.hasValue ? availabilityState.value! : false;
    final isLoading = availabilityState.isLoading;

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isOnline ? Icons.check_circle : Icons.offline_bolt,
                  color: isOnline ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'You are Online' : 'You are Offline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (isLoading)
              const CircularProgressIndicator()
            else
              Switch(
                value: isOnline,
                onChanged: (value) async {
                  final failure = await ref.read(availabilityControllerProvider.notifier).toggleStatus();
                  if (failure != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(failure.message)),
                    );
                  }
                },
                activeColor: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}
