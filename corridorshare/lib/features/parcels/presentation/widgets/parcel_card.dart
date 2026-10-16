import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParcelCard extends StatelessWidget {
  const ParcelCard({
    required this.parcel,
    this.onTap,
    super.key,
  });

  final Parcel parcel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('d MMM');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header: Title and Offered Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          parcel.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sender: ${parcel.senderName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '৳ ${parcel.offeredPrice.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _StatusChip(status: parcel.status, l10n: l10n),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Route
              Row(
                children: <Widget>[
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${parcel.fromDistrict} → ${parcel.toDistrict}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Before ${dateFormat.format(parcel.deadline)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Badges: Weight, Size, Category Tags
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: <Widget>[
                  _TagBadge(
                    icon: Icons.scale_outlined,
                    label: '${parcel.weightKg.toStringAsFixed(1)} kg',
                  ),
                  _TagBadge(
                    icon: Icons.inventory_2_outlined,
                    label: parcel.size.name.toUpperCase(),
                  ),
                  ...parcel.categoryTags.map(
                    (tag) => _TagBadge(icon: Icons.tag, label: tag),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});

  final ParcelStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    String label;

    switch (status) {
      case ParcelStatus.open:
        color = Colors.green;
        label = l10n.statusOpen;
        break;
      case ParcelStatus.matched:
        color = Colors.blue;
        label = l10n.statusMatched;
        break;
      case ParcelStatus.inTransit:
        color = Colors.orange;
        label = l10n.statusInTransit;
        break;
      case ParcelStatus.delivered:
        color = theme.colorScheme.primary;
        label = l10n.statusDelivered;
        break;
      case ParcelStatus.cancelled:
        color = theme.colorScheme.error;
        label = l10n.statusCancelled;
        break;
      case ParcelStatus.disputed:
        color = Colors.purple;
        label = l10n.statusDisputed;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
