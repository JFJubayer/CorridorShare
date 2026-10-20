import 'dart:math';

import 'package:corridorshare/features/matching/domain/entities/match_check.dart';
import 'package:corridorshare/features/matching/domain/entities/route_match_result.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';

/// Intelligent routing and corridor auto-matching engine for CorridorShare.
class RouteMatchEngine {
  const RouteMatchEngine._();

  /// Known major highway corridors in Bangladesh (ordered from start to end).
  static const List<List<String>> _corridors = <List<String>>[
    // Dhaka - Mymensingh Highway Corridor
    <String>['Dhaka', 'Gazipur', 'Mymensingh'],

    // Dhaka - Chattogram Highway Corridor
    <String>['Dhaka', 'Narayanganj', 'Munshiganj', 'Cumilla', 'Feni', 'Chattogram'],

    // Dhaka - Sylhet Highway Corridor
    <String>[
      'Dhaka',
      'Narayanganj',
      'Narsingdi',
      'Brahmanbaria',
      'Kishoreganj',
      'Habiganj',
      'Moulvibazar',
      'Sylhet',
    ],

    // Dhaka - Rajshahi Corridor
    <String>['Dhaka', 'Manikganj', 'Tangail', 'Sirajganj', 'Natore', 'Rajshahi'],

    // Dhaka - Khulna Corridor
    <String>['Dhaka', 'Munshiganj', 'Madaripur', 'Gopalganj', 'Bagerhat', 'Khulna'],

    // Dhaka - Barishal Corridor
    <String>['Dhaka', 'Munshiganj', 'Madaripur', 'Barishal'],

    // Dhaka - Bogura - Rangpur Corridor
    <String>['Dhaka', 'Tangail', 'Sirajganj', 'Bogura', 'Gaibandha', 'Rangpur'],

    // Chattogram - Cox's Bazar Corridor
    <String>['Chattogram', 'Cox\'s Bazar'],
  ];

  /// Known upazila/sub-district detour distances off the main highway corridor (in km).
  static const Map<String, int> _knownDetourDistances = <String, int>{
    'muktagacha': 20,
    'gafargaon': 25,
    'phulpur': 24,
    'haluaghat': 45,
    'bhaluka': 6,
    'trishal': 6,
    'sitakunda': 8,
    'mirsharai': 10,
    'hathazari': 18,
    'sreemangal': 14,
    'savar': 12,
    'dhamrai': 18,
    'nabinagar': 22,
    'sreepur': 10,
  };

  /// Analyzes and auto-matches a list of candidate parcels against a trip travel route.
  /// Returns auto-matched results sorted by match score descending.
  static List<RouteMatchResult> autoMatchParcelsForTrip({
    required Trip trip,
    required List<Parcel> allParcels,
  }) {
    final validParcels = allParcels
        .where((p) => p.status == ParcelStatus.open)
        .toList();

    // 1. Initial evaluation
    final candidateResults = <RouteMatchResult>[];
    for (final parcel in validParcels) {
      final res = evaluate(trip: trip, parcel: parcel);
      if (res.compatibilityType != RouteCompatibilityType.incompatible) {
        candidateResults.add(res);
      }
    }

    // 2. Identify top scoring parcel for the "Best match" badge
    final unblocked = candidateResults
        .where((r) => !r.isBlockedByRestrictions)
        .toList();

    if (unblocked.isEmpty) {
      return candidateResults;
    }

    unblocked.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    final topParcelId = unblocked.first.parcel.id;

    // 3. Re-evaluate with topScore flag for accurate badge assignment
    return candidateResults.map((result) {
      if (result.parcel.id == topParcelId) {
        return evaluate(
          trip: trip,
          parcel: result.parcel,
          isTopScore: true,
        );
      }
      return result;
    }).toList();
  }

  /// Evaluates compatibility and detour between a trip and a parcel.
  static RouteMatchResult evaluate({
    required Trip trip,
    required Parcel parcel,
    bool isTopScore = false,
  }) {
    final normTripFrom = trip.fromDistrict.trim().toLowerCase();
    final normTripTo = trip.toDistrict.trim().toLowerCase();
    final normParcelFrom = parcel.fromDistrict.trim().toLowerCase();
    final normParcelTo = parcel.toDistrict.trim().toLowerCase();

    final remainingCapacity = max(0.0, trip.capacityKg - trip.bookedKg);
    final freeKg = remainingCapacity > 0 ? remainingCapacity : trip.capacityKg;
    final freeKgFormatted = freeKg.truncateToDouble() == freeKg
        ? freeKg.toInt().toString()
        : freeKg.toStringAsFixed(1);

    // 1. Check prohibited categories vs traveller's no-carry tags
    final isBlocked = MatchCheck.isBlockedByNoCarry(trip: trip, parcel: parcel);
    String? blockedReason;
    if (isBlocked) {
      final hitTags = parcel.categoryTags.where((t) {
        final norm = t.trim().toLowerCase();
        return trip.noCarryTags.any((nt) =>
            norm.contains(nt.trim().toLowerCase()) ||
            nt.trim().toLowerCase().contains(norm));
      }).toList();
      blockedReason = 'Contains items you won\'t carry: ${hitTags.join(", ")}';
    }

    // 2. Determine corridor alignment and detour
    RouteCompatibilityType compatibilityType = RouteCompatibilityType.incompatible;
    int detourKm = 0;

    // Check direct route match
    if (normTripFrom == normParcelFrom && normTripTo == normParcelTo) {
      detourKm = _estimateAreaDetour(parcel);
      compatibilityType = detourKm > 0
          ? RouteCompatibilityType.minorDetour
          : RouteCompatibilityType.directRoute;
    } else {
      // Check sub-corridor sequential alignment
      final onCorridor = _checkCorridorAlignment(
        tripFrom: normTripFrom,
        tripTo: normTripTo,
        parcelFrom: normParcelFrom,
        parcelTo: normParcelTo,
      );

      if (onCorridor) {
        detourKm = _estimateAreaDetour(parcel);
        compatibilityType = detourKm > 0
            ? RouteCompatibilityType.minorDetour
            : RouteCompatibilityType.onCorridor;
      }
    }

    // 3. Check capacity compatibility
    final isCapacityOk = parcel.weightKg <= (freeKg + 0.05);
    if (!isCapacityOk && !isBlocked) {
      // If capacity exceeded, mark incompatible
      compatibilityType = RouteCompatibilityType.incompatible;
    }

    // 4. Calculate intelligent match score (0 to 100)
    double score = 0.0;
    if (compatibilityType != RouteCompatibilityType.incompatible) {
      // Route alignment points (max 45)
      if (compatibilityType == RouteCompatibilityType.directRoute) {
        score += 45;
      } else if (compatibilityType == RouteCompatibilityType.onCorridor) {
        score += 38;
      } else {
        // Minor detour penalty
        score += max(15.0, 35.0 - (detourKm * 0.8));
      }

      // Reward density points (max 30)
      final ratePerKg = parcel.offeredPrice / max(1.0, parcel.weightKg);
      score += min(30.0, ratePerKg * 0.12);

      // Capacity fit points (max 15)
      final capacityFillFraction = parcel.weightKg / max(1.0, freeKg);
      score += min(15.0, capacityFillFraction * 15.0);

      // Date flexibility bonus (max 10)
      if (MatchCheck.isDateCompatible(trip: trip, parcel: parcel)) {
        score += 10;
      }
    }

    // 5. Build presentation badges
    final badges = <String>[];
    if (isTopScore && !isBlocked) {
      badges.add('Best match');
    }

    if (detourKm == 0) {
      badges.add('On your route');
    } else {
      badges.add('Detour $detourKm km');
    }

    badges.add('Fits $freeKgFormatted kg');

    final routeSummary =
        '${parcel.fromArea.isNotEmpty ? parcel.fromArea : parcel.fromDistrict} → ${parcel.toArea.isNotEmpty ? parcel.toArea : parcel.toDistrict}';

    return RouteMatchResult(
      parcel: parcel,
      trip: trip,
      compatibilityType: compatibilityType,
      detourKm: detourKm,
      matchScore: score.clamp(0.0, 100.0),
      isBestMatch: isTopScore && !isBlocked,
      isBlockedByRestrictions: isBlocked,
      blockedReason: blockedReason,
      badges: badges,
      routeSummary: routeSummary,
    );
  }

  /// Checks if parcel's origin and destination lie sequentially along the trip's corridor.
  static bool _checkCorridorAlignment({
    required String tripFrom,
    required String tripTo,
    required String parcelFrom,
    required String parcelTo,
  }) {
    for (final corridor in _corridors) {
      final normCorridor = corridor.map((d) => d.toLowerCase()).toList();
      final tripStartIdx = normCorridor.indexOf(tripFrom);
      final tripEndIdx = normCorridor.indexOf(tripTo);

      if (tripStartIdx != -1 && tripEndIdx != -1) {
        final parcelStartIdx = normCorridor.indexOf(parcelFrom);
        final parcelEndIdx = normCorridor.indexOf(parcelTo);

        if (parcelStartIdx != -1 && parcelEndIdx != -1) {
          // Forward direction along corridor
          if (tripStartIdx < tripEndIdx) {
            if (parcelStartIdx >= tripStartIdx &&
                parcelEndIdx <= tripEndIdx &&
                parcelStartIdx < parcelEndIdx) {
              return true;
            }
          }
          // Reverse direction along corridor
          else if (tripStartIdx > tripEndIdx) {
            if (parcelStartIdx <= tripStartIdx &&
                parcelEndIdx >= tripEndIdx &&
                parcelStartIdx > parcelEndIdx) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  /// Estimates detour in kilometers based on specific upazilas or pickup/drop-off areas.
  static int _estimateAreaDetour(Parcel parcel) {
    final combined = '${parcel.fromArea} ${parcel.toArea}'.toLowerCase();
    for (final entry in _knownDetourDistances.entries) {
      if (combined.contains(entry.key)) {
        return entry.value;
      }
    }
    return 0;
  }
}
