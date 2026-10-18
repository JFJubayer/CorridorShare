import 'package:corridorshare/core/theme/app_colors.dart';
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

  String _toCode(String district) {
    if (district.isEmpty) return 'LOC';
    final cleaned = district.trim().toUpperCase();
    return cleaned.length >= 3 ? cleaned.substring(0, 3) : cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final timeFormat = DateFormat('h:mma');
    final dateFormat = DateFormat('EEE, d MMM');

    final depTime = timeFormat.format(trip.departureDate).toLowerCase();
    final depDate = dateFormat.format(trip.departureDate);
    // Estimated arrival ~4 hours later or next day representation
    final arrTime = timeFormat
        .format(trip.departureDate.add(const Duration(hours: 4)))
        .toLowerCase();
    final arrDate =
        dateFormat.format(trip.departureDate.add(const Duration(hours: 4)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Left Vertical Ribbon (Lime with vertical text & transit icon)
                Container(
                  width: 52,
                  color: AppColors.limeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(height: 6),
                      const RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'TRAVELLER',
                          style: TextStyle(
                            color: AppColors.darkCharcoal,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.darkCharcoal,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flight,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Ticket Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Upper Route & Times Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Column(
                          children: <Widget>[
                            // Route: Origin -> Flight Badge -> Destination
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // Origin
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _toCode(trip.fromDistrict),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.darkCharcoal,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        trip.fromDistrict,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.ticketMutedText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // Center Transit Badge
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF0EEE4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.flight_takeoff,
                                    size: 16,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),

                                // Destination
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        _toCode(trip.toDistrict),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.darkCharcoal,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        trip.toDistrict,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.ticketMutedText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Departure & Arrival times row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      depTime,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkCharcoal,
                                      ),
                                    ),
                                    Text(
                                      depDate,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.ticketMutedText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      arrTime,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkCharcoal,
                                      ),
                                    ),
                                    Text(
                                      arrDate,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.ticketMutedText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Optional restriction tags / note if any
                      if (trip.noCarryTags.isNotEmpty ||
                          (trip.note != null && trip.note!.isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: <Widget>[
                              if (trip.noCarryTags.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'No: ${trip.noCarryTags.join(", ")}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Bottom Tinted Info Strip (Yellow / Lime tinted)
                      Container(
                        color: AppColors.ticketYellow,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Seats / Capacity
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Capacity',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.ticketMutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${trip.capacityKg.toStringAsFixed(1)} kg',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ticketDarkText,
                                  ),
                                ),
                              ],
                            ),

                            // Traveller Name
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const Text(
                                      'Traveller',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.ticketMutedText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      trip.travellerName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.ticketDarkText,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Status
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                const Text(
                                  'Status',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.ticketMutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                _StatusLabel(status: trip.status, l10n: l10n),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status, required this.l10n});

  final TripStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case TripStatus.open:
        color = const Color(0xFF1B7F4D);
        label = l10n.statusOpen;
        break;
      case TripStatus.full:
        color = const Color(0xFFC97A0E);
        label = l10n.statusFull;
        break;
      case TripStatus.completed:
        color = AppColors.brand;
        label = l10n.statusCompleted;
        break;
      case TripStatus.cancelled:
        color = AppColors.danger;
        label = l10n.statusCancelled;
        break;
    }

    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
