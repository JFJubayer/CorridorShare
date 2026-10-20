import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Public read-only parcel details sheet displayed to travellers browsing packages.
/// Protects sender authority and prevents unauthorized users from accepting/managing deals.
class ParcelDetailsSheet extends ConsumerWidget {
  const ParcelDetailsSheet({
    required this.parcel,
    super.key,
  });

  final Parcel parcel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy');
    final formattedDeadline = dateFormat.format(parcel.deadline);
    final currentUser = ref.watch(currentUserProvider);
    final myTripsAsync = ref.watch(myTripsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF6F5EE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Grabber handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title & Close Button
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'PARCEL REQUEST',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7E867B),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${parcel.title} · ${parcel.weightKg.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.darkCharcoal),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Parcel Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE8E6DB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Route
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.place_outlined,
                        size: 18,
                        color: AppColors.darkCharcoal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${parcel.fromDistrict} (${parcel.fromArea.isNotEmpty ? parcel.fromArea : "City"}) → ${parcel.toDistrict} (${parcel.toArea.isNotEmpty ? parcel.toArea : "City"})',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Deadline
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.event_outlined,
                        size: 18,
                        color: AppColors.darkCharcoal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Needed by: $formattedDeadline',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Sender profile
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: AppColors.darkCharcoal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        parcel.senderName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Color(0xFF74A727),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '· Verified Sender',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6E786B),
                        ),
                      ),
                    ],
                  ),

                  // Offered fee
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFEAE7DC), height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Sender\'s Proposed Reward:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6E786B),
                        ),
                      ),
                      Text(
                        '৳${parcel.offeredPrice.toInt()}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: <Widget>[
                // Chat button
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('${AppRoutes.chats}/sender_${parcel.senderId}');
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.darkCharcoal,
                    side: const BorderSide(color: AppColors.cardBorder),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Offer to carry with my trip
                Expanded(
                  child: FilledButton(
                    key: const Key('offerToCarryButton'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      myTripsAsync.when(
                        data: (trips) {
                          final openTrips = trips
                              .where((t) => t.status == TripStatus.open)
                              .toList();
                          if (openTrips.isNotEmpty) {
                            // User has open trips - let them choose one to carry this parcel
                            _showSelectTripSheet(context, parcel, openTrips, currentUser?.id ?? 'user');
                          } else {
                            // Prompt traveller to post a trip first
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post your trip first to offer carrying this parcel.'),
                                backgroundColor: AppColors.darkCharcoal,
                              ),
                            );
                            context.push(AppRoutes.newTrip);
                          }
                        },
                        loading: () {},
                        error: (_, __) {},
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.darkCharcoal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Offer to carry',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectTripSheet(
    BuildContext context,
    Parcel parcel,
    List<dynamic> openTrips,
    String currentUserId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF6F5EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Select your trip to carry this parcel:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 12),
                ...openTrips.map((t) => ListTile(
                      title: Text('${t.fromDistrict} → ${t.toDistrict}'),
                      subtitle: Text('${t.capacityKg} kg capacity'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        final rootNav = Navigator.of(context, rootNavigator: true);
                        Navigator.of(sheetContext).pop();
                        if (!rootNav.context.mounted) return;
                        showModalBottomSheet<void>(
                          context: rootNav.context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          backgroundColor: const Color(0xFFF6F5EE),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          builder: (context) => MakeOfferSheet(
                            trip: t,
                            parcel: parcel,
                            currentUserId: currentUserId,
                          ),
                        );
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
