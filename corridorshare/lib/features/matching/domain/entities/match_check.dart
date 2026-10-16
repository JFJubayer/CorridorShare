import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';

class MatchCheck {
  const MatchCheck._();

  /// Returns true if a parcel contains any category tag that is present in
  /// the traveller's no-carry restriction list.
  static bool isBlockedByNoCarry({
    required Trip trip,
    required Parcel parcel,
  }) {
    if (trip.noCarryTags.isEmpty || parcel.categoryTags.isEmpty) {
      return false;
    }

    final normalizedNoCarry = trip.noCarryTags
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    for (final tag in parcel.categoryTags) {
      final normalized = tag.trim().toLowerCase();
      if (normalizedNoCarry.contains(normalized)) {
        return true;
      }
      // Check partial substring match (e.g. "liquid" in "liquids")
      for (final noCarry in normalizedNoCarry) {
        if (normalized.contains(noCarry) || noCarry.contains(normalized)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Checks if a trip and parcel form a valid routing match.
  static bool isRouteCompatible({
    required Trip trip,
    required Parcel parcel,
  }) {
    final sameOrigin = trip.fromDistrict.trim().toLowerCase() ==
        parcel.fromDistrict.trim().toLowerCase();
    final sameDestination = trip.toDistrict.trim().toLowerCase() ==
        parcel.toDistrict.trim().toLowerCase();
    return sameOrigin && sameDestination;
  }

  /// Checks if the trip departure occurs on or before parcel deadline.
  static bool isDateCompatible({
    required Trip trip,
    required Parcel parcel,
  }) {
    final dep = DateTime(
      trip.departureDate.year,
      trip.departureDate.month,
      trip.departureDate.day,
    );
    final deadline = DateTime(
      parcel.deadline.year,
      parcel.deadline.month,
      parcel.deadline.day,
    );
    return !dep.isAfter(deadline);
  }

  /// Checks if the trip has sufficient weight capacity.
  static bool isCapacityCompatible({
    required Trip trip,
    required Parcel parcel,
  }) {
    return parcel.weightKg <= trip.capacityKg;
  }
}
