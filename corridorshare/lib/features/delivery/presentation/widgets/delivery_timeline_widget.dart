import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DeliveryTimelineWidget extends StatelessWidget {
  const DeliveryTimelineWidget({
    required this.delivery,
    super.key,
  });

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('d MMM, h:mm a');

    final isMatchedDone = true;
    final isInTransitDone = delivery.status == DeliveryStatus.inTransit ||
        delivery.status == DeliveryStatus.delivered;
    final isDeliveredDone = delivery.status == DeliveryStatus.delivered;
    final isDisputed = delivery.status == DeliveryStatus.disputed;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  l10n.deliveryTrackingTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _StatusBadge(status: delivery.status, l10n: l10n),
              ],
            ),
            const SizedBox(height: 20),

            // Step 1: Matched / Deal Agreed
            _TimelineStep(
              stepNumber: '1',
              title: l10n.deliveryStepMatched,
              subtitle: '${l10n.dealAgreedBadge} • ${dateFormat.format(delivery.createdAt)}',
              isCompleted: isMatchedDone,
              isCurrent: delivery.status == DeliveryStatus.matched,
            ),
            _TimelineConnector(isCompleted: isInTransitDone),

            // Step 2: Picked Up / In Transit
            _TimelineStep(
              stepNumber: '2',
              title: l10n.deliveryStepInTransit,
              subtitle: delivery.pickedUpAt != null
                  ? '${l10n.deliveryPickedUpAt} ${dateFormat.format(delivery.pickedUpAt!)}'
                  : l10n.deliveryAwaitingPickup,
              isCompleted: isInTransitDone,
              isCurrent: delivery.status == DeliveryStatus.inTransit,
            ),
            _TimelineConnector(isCompleted: isDeliveredDone),

            // Step 3: Delivered
            _TimelineStep(
              stepNumber: '3',
              title: l10n.deliveryStepDelivered,
              subtitle: delivery.deliveredAt != null
                  ? '${l10n.deliveryCompletedAt} ${dateFormat.format(delivery.deliveredAt!)}'
                  : l10n.deliveryPendingHandover,
              isCompleted: isDeliveredDone,
              isCurrent: delivery.status == DeliveryStatus.delivered,
            ),

            if (isDisputed) ...<Widget>[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.disputeRaisedTitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            delivery.disputeReason ?? l10n.statusDisputed,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.l10n});

  final DeliveryStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case DeliveryStatus.matched:
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        label = l10n.deliveryStepMatched;
      case DeliveryStatus.inTransit:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        label = l10n.deliveryStepInTransit;
      case DeliveryStatus.delivered:
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        label = l10n.deliveryStepDelivered;
      case DeliveryStatus.disputed:
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        label = l10n.statusDisputed;
      case DeliveryStatus.cancelled:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = l10n.statusCancelled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
  });

  final String stepNumber;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = isCompleted
        ? theme.colorScheme.primary
        : (isCurrent
            ? theme.colorScheme.secondary
            : theme.colorScheme.outlineVariant);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        CircleAvatar(
          radius: 12,
          backgroundColor: indicatorColor,
          child: isCompleted
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  stepNumber,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCompleted || isCurrent
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 11),
      child: Container(
        width: 2,
        height: 20,
        color: isCompleted
            ? theme.colorScheme.primary
            : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
