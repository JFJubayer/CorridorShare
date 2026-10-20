import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Public read-only trip overview sheet displayed to users browsing travellers.
/// Protects traveller privacy and prevents unauthorized users from managing deals.
class TripDetailsSheet extends ConsumerWidget {
  const TripDetailsSheet({
    required this.trip,
    super.key,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy, h:mm a');
    final formattedDate = dateFormat.format(trip.departureDate);
    final freeKg = (trip.capacityKg - trip.bookedKg).clamp(0.0, 999.0);
    final currentUser = ref.watch(currentUserProvider);
    final myParcelsAsync = ref.watch(myParcelsProvider);

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

            // Corridor Title & Close Button
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'TRAVELLER ROUTE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7E867B),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${trip.fromDistrict} → ${trip.toDistrict}',
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

            // Trip Info Card
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
                  // Departure
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: AppColors.darkCharcoal,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Capacity
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.scale_rounded,
                        size: 18,
                        color: AppColors.darkCharcoal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available capacity: ${freeKg.toStringAsFixed(1)} of ${trip.capacityKg.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Traveller profile
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: AppColors.darkCharcoal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        trip.travellerName,
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
                        '· Verified Traveller',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6E786B),
                        ),
                      ),
                    ],
                  ),

                  // Prohibited restrictions
                  if (trip.noCarryTags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFEAE7DC), height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        const Text(
                          "WON'T CARRY: ",
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFA84242),
                            letterSpacing: 0.8,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            trip.noCarryTags.join(', '),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFA84242),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (trip.note != null && trip.note!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Note: ${trip.note}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF6E786B),
                      ),
                    ),
                  ],
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
                    context.push('${AppRoutes.chats}/traveller_${trip.travellerId}');
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

                // Request with my parcel
                Expanded(
                  child: FilledButton(
                    key: const Key('requestTravellerButton'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      myParcelsAsync.when(
                        data: (parcels) {
                          final openParcels = parcels
                              .where((p) => p.status == ParcelStatus.open)
                              .toList();
                          if (openParcels.isNotEmpty) {
                            // User has open parcels - let them choose one to send offer
                            _showSelectParcelSheet(context, trip, openParcels, currentUser?.id ?? 'user');
                          } else {
                            // Prompt user to post a parcel for this route
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Post your parcel first to request this traveller.'),
                                backgroundColor: AppColors.darkCharcoal,
                              ),
                            );
                            context.push(AppRoutes.newParcel);
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
                      'Request with my parcel',
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

  void _showSelectParcelSheet(
    BuildContext context,
    Trip trip,
    List<dynamic> openParcels,
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
                  'Select your parcel to send to traveller:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 12),
                ...openParcels.map((p) => ListTile(
                      title: Text(p.title),
                      subtitle: Text('${p.fromDistrict} → ${p.toDistrict} · ${p.weightKg} kg'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: const Color(0xFFF6F5EE),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                          ),
                          builder: (context) => MakeOfferSheet(
                            trip: trip,
                            parcel: p,
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
