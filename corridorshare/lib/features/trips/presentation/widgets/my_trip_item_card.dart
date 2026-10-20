import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/matching/domain/services/route_match_engine.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyTripItemCard extends ConsumerWidget {
  const MyTripItemCard({
    required this.trip,
    super.key,
  });

  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('EEE d MMM, h:mm a');
    final formattedDate = dateFormat.format(trip.departureDate);

    final bookedKg = trip.bookedKg;
    final capacityKg = trip.capacityKg;
    final progress = capacityKg > 0 ? (bookedKg / capacityKg).clamp(0.0, 1.0) : 0.0;

    final bookedText = bookedKg.truncateToDouble() == bookedKg
        ? bookedKg.toInt().toString()
        : bookedKg.toStringAsFixed(1);
    final capacityText = capacityKg.truncateToDouble() == capacityKg
        ? capacityKg.toInt().toString()
        : capacityKg.toStringAsFixed(1);

    // Live calculation of matching parcels for this travel route
    final parcelsAsync = ref.watch(allOpenParcelsProvider);
    final int dynamicMatchingCount = parcelsAsync.maybeWhen(
      data: (parcels) {
        final matches = RouteMatchEngine.autoMatchParcelsForTrip(
          trip: trip,
          allParcels: parcels,
        );
        return matches.where((m) => m.isMatch).length;
      },
      orElse: () => ref.watch(parcelsFeedProvider).maybeWhen(
        data: (parcels) {
          final matches = RouteMatchEngine.autoMatchParcelsForTrip(
            trip: trip,
            allParcels: parcels,
          );
          return matches.where((m) => m.isMatch).length;
        },
        orElse: () => trip.matchingParcelsCount,
      ),
    );
    final matchingCount = dynamicMatchingCount > 0
        ? dynamicMatchingCount
        : trip.matchingParcelsCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E6DB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Row: Route & Status Badge
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${trip.fromDistrict} → ${trip.toDistrict}',
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFBDDC37),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Open',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // Departure Date & Time
          Text(
            formattedDate,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6E786B),
            ),
          ),
          const SizedBox(height: 14),

          // Capacity Progress Bar & Label
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFEAE7DC),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF98CB3B),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '$bookedText of $capacityText kg booked',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions Row: Edit & Matching parcels / Share trip
          Row(
            children: <Widget>[
              FilledButton(
                key: Key('editTripButton_${trip.id}'),
                onPressed: () {
                  context.push(AppRoutes.newTrip, extra: trip);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(100, 46),
                  backgroundColor: const Color(0xFFEAE7DC),
                  foregroundColor: AppColors.darkCharcoal,
                  shape: const StadiumBorder(),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  key: Key('matchingParcelsButton_${trip.id}'),
                  onPressed: () {
                    context.push('${AppRoutes.match}?tripId=${trip.id}');
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 46),
                    backgroundColor: const Color(0xFF16211A),
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Matching parcels ',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$matchingCount',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFBDDC37),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
