import 'package:corridorshare/features/admin/domain/entities/platform_metrics.dart';
import 'package:corridorshare/features/admin/presentation/providers/admin_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final metricsAsync = ref.watch(platformMetricsProvider);
    final disputedAsync = ref.watch(disputedDeliveriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboardTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.adminOverviewTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // KPI Grid
            metricsAsync.when(
              data: (metrics) => _MetricsGrid(metrics: metrics, l10n: l10n),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(child: Text(err.toString())),
            ),
            const SizedBox(height: 24),

            // Dispute Management Queue
            Row(
              children: <Widget>[
                const Icon(Icons.gavel, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  l10n.adminDisputeQueueTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            disputedAsync.when(
              data: (disputedList) {
                if (disputedList.isEmpty) {
                  return Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: <Widget>[
                            const Icon(
                              Icons.check_circle_outline,
                              size: 40,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.adminNoOpenDisputes,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: disputedList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final delivery = disputedList[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.error.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    delivery.parcelTitle,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  '৳ ${delivery.agreedPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${delivery.fromDistrict} → ${delivery.toDistrict}',
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${l10n.adminDisputeReason}: ${delivery.disputeReason ?? ""}',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: OutlinedButton(
                                    key: Key('refundSenderButton_${delivery.id}'),
                                    onPressed: () {
                                      ref
                                          .read(adminActionControllerProvider
                                              .notifier)
                                          .resolveDispute(
                                            deliveryId: delivery.id,
                                            resolution:
                                                DisputeResolution.refundSender,
                                            adminNotes: 'Admin approved refund',
                                          );
                                    },
                                    child: Text(l10n.adminRefundSenderAction),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: FilledButton(
                                    key: Key('payoutTravellerButton_${delivery.id}'),
                                    onPressed: () {
                                      ref
                                          .read(adminActionControllerProvider
                                              .notifier)
                                          .resolveDispute(
                                            deliveryId: delivery.id,
                                            resolution: DisputeResolution
                                                .payoutTraveller,
                                            adminNotes: 'Admin approved payout',
                                          );
                                    },
                                    child: Text(l10n.adminPayoutTravellerAction),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text(err.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics, required this.l10n});

  final PlatformMetrics metrics;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        _MetricTile(
          icon: Icons.people_outline,
          label: l10n.adminTotalUsers,
          value: metrics.totalUsers.toString(),
          color: Colors.blue,
        ),
        _MetricTile(
          icon: Icons.alt_route,
          label: l10n.adminTotalTrips,
          value: metrics.totalTrips.toString(),
          color: Colors.indigo,
        ),
        _MetricTile(
          icon: Icons.local_shipping_outlined,
          label: l10n.adminActiveDeliveries,
          value: metrics.activeDeliveries.toString(),
          color: Colors.teal,
        ),
        _MetricTile(
          icon: Icons.currency_lira,
          label: l10n.adminTotalVolume,
          value: '৳${metrics.totalVolumeBdt.toStringAsFixed(0)}',
          color: Colors.green,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: color, size: 22),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
