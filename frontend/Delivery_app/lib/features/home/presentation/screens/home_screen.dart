import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/availability/presentation/widgets/availability_toggle.dart';

import '../../../../features/assignment/presentation/providers/assignment_providers.dart';
import '../../../../features/assignment/domain/entities/delivery_status.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(pendingOffersProvider);
    final activeAssignment = ref.watch(assignmentControllerProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Partner'),
      ),
      body: Column(
        children: [
          const AvailabilityToggle(),
          Expanded(
            child: activeAssignment != null && activeAssignment.status != DeliveryStatus.pending
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('You have an active assignment!'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.push('/assignment/${activeAssignment.orderId}');
                          },
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  )
                : offersAsync.when(
                    data: (offers) {
                      if (offers.isEmpty) {
                        return const Center(child: Text('No pending orders nearby.'));
                      }
                      return ListView.builder(
                        itemCount: offers.length,
                        itemBuilder: (context, index) {
                          final offer = offers[index];
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text('Order: ${offer.orderId.substring(0, 8)}'),
                              subtitle: const Text('New delivery request'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  ref.read(assignmentControllerProvider.notifier).acceptOffer(offer);
                                },
                                child: const Text('Accept'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Error fetching offers: $error')),
                  ),
          ),
        ],
      ),
    );
  }
}
