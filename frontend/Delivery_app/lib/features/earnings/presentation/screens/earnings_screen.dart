import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/earnings_providers.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsState = ref.watch(earningsControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(earningsControllerProvider);
          await ref.read(earningsControllerProvider.future);
        },
        child: earningsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (info) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Today Summary Card
                Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Today\'s Earnings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currencyFormat.format(info.todayEarnings),
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text('${info.todayDeliveries} Deliveries Completed'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Week & Total Summary
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'This Week',
                        amount: currencyFormat.format(info.weekEarnings),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Earnings',
                        amount: currencyFormat.format(info.totalEarnings),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Recent Deliveries
                Text(
                  'Recent Deliveries',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (info.recentRecords.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No deliveries yet.')),
                  )
                else
                  ...info.recentRecords.map((record) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.secondaryContainer,
                      child: Icon(Icons.delivery_dining, color: colorScheme.onSecondaryContainer),
                    ),
                    title: Text(record.dropAddress, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(DateFormat('MMM d, h:mm a').format(record.deliveredAt)),
                    trailing: Text(
                      currencyFormat.format(record.payout),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  )),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;

  const _SummaryCard({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(amount, style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            )),
          ],
        ),
      ),
    );
  }
}
