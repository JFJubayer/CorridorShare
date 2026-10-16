import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TripCard extends StatelessWidget {
  const TripCard({
    required this.trip,
    this.onTap,
    super.key,
  });

  final Trip trip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('EEE, d MMM');

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
              // Header: Traveller & Status
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      trip.travellerName.isNotEmpty
                          ? trip.travellerName[0].toUpperCase()
                          : 'T',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          trip.travellerName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          dateFormat.format(trip.departureDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(status: trip.status, l10n: l10n),
                ],
              ),
              const SizedBox(height: 14),

              // Route representation
              Row(
                children: <Widget>[
                  Icon(
                    Icons.trip_origin,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          trip.fromDistrict,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (trip.fromArea.isNotEmpty)
                          Text(
                            trip.fromArea,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          trip.toDistrict,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (trip.toArea.isNotEmpty)
                          Text(
                            trip.toArea,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Capacity and Tags
              Row(
                children: <Widget>[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trip.capacityKg.toStringAsFixed(1)} kg max',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (trip.noCarryTags.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.block,
                          size: 14,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'No ${trip.noCarryTags.join(", ")}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (trip.note != null && trip.note!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  trip.note!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.l10n});

  final TripStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    String label;

    switch (status) {
      case TripStatus.open:
        color = Colors.green;
        label = l10n.statusOpen;
        break;
      case TripStatus.full:
        color = Colors.orange;
        label = l10n.statusFull;
        break;
      case TripStatus.completed:
        color = theme.colorScheme.primary;
        label = l10n.statusCompleted;
        break;
      case TripStatus.cancelled:
        color = theme.colorScheme.error;
        label = l10n.statusCancelled;
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
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
