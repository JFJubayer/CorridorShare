import 'package:corridorshare/core/theme/app_colors.dart';
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

  String _toCode(String district) {
    if (district.isEmpty) return 'LOC';
    final cleaned = district.trim().toUpperCase();
    return cleaned.length >= 3 ? cleaned.substring(0, 3) : cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('EEE, d MMM');
    final deadlineDate = dateFormat.format(parcel.deadline);

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
                // Left Vertical Ribbon (Dark charcoal with vertical text & parcel icon)
                Container(
                  width: 52,
                  color: AppColors.darkCharcoal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(height: 6),
                      const RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          'PARCEL',
                          style: TextStyle(
                            color: AppColors.limeAccent,
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
                          color: AppColors.limeAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.darkCharcoal,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Upper Route & Item Section
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Route: Origin -> Box Badge -> Destination
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
                                        _toCode(parcel.fromDistrict),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.darkCharcoal,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        parcel.fromDistrict,
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
                                    Icons.arrow_forward,
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
                                        _toCode(parcel.toDistrict),
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.darkCharcoal,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        parcel.toDistrict,
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

                            const SizedBox(height: 10),

                            // Item Title & Deadline
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    parcel.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkCharcoal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'By $deadlineDate',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.ticketMutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                            if (parcel.categoryTags.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: parcel.categoryTags.take(3).map((tag) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0EEE4),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '#$tag',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.ticketMutedText,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Bottom Tinted Info Strip
                      Container(
                        color: AppColors.ticketYellow,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Weight
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  'Weight',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.ticketMutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${parcel.weightKg.toStringAsFixed(1)} kg',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ticketDarkText,
                                  ),
                                ),
                              ],
                            ),

                            // Reward
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                const Text(
                                  'Reward',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.ticketMutedText,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '৳ ${parcel.offeredPrice.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ticketDarkText,
                                  ),
                                ),
                              ],
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
                                _ParcelStatusLabel(
                                    status: parcel.status, l10n: l10n),
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

class _ParcelStatusLabel extends StatelessWidget {
  const _ParcelStatusLabel({required this.status, required this.l10n});

  final ParcelStatus status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case ParcelStatus.open:
        color = const Color(0xFF1B7F4D);
        label = l10n.statusOpen;
        break;
      case ParcelStatus.matched:
        color = const Color(0xFFC97A0E);
        label = l10n.statusMatched;
        break;
      case ParcelStatus.inTransit:
        color = AppColors.brand;
        label = l10n.statusInTransit;
        break;
      case ParcelStatus.delivered:
        color = const Color(0xFF1B7F4D);
        label = l10n.statusDelivered;
        break;
      case ParcelStatus.cancelled:
        color = AppColors.danger;
        label = l10n.statusCancelled;
        break;
      case ParcelStatus.disputed:
        color = AppColors.danger;
        label = l10n.statusDisputed;
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
