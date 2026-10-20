import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';

enum RouteCompatibilityType {
  /// Exact match between trip corridor and parcel corridor (e.g. Dhaka -> Mymensingh).
  directRoute,

  /// Parcel pickup and dropoff lie sequentially on the trip highway corridor
  /// (e.g. Trip Dhaka -> Sylhet; Parcel Narsingdi -> Brahmanbaria).
  onCorridor,

  /// Parcel requires a minor detour from the corridor highway
  /// (e.g. Mymensingh Sadar -> Muktagacha detour).
  minorDetour,

  /// Parcel is outside the trip's corridor.
  incompatible,
}

/// Represents the auto-match analysis result of a parcel against a traveller's trip route.
class RouteMatchResult {
  const RouteMatchResult({
    required this.parcel,
    required this.trip,
    required this.compatibilityType,
    required this.detourKm,
    required this.matchScore,
    required this.isBestMatch,
    required this.isBlockedByRestrictions,
    required this.blockedReason,
    required this.badges,
    required this.routeSummary,
  });

  final Parcel parcel;
  final Trip trip;
  final RouteCompatibilityType compatibilityType;
  final int detourKm;
  final double matchScore;
  final bool isBestMatch;
  final bool isBlockedByRestrictions;
  final String? blockedReason;
  final List<String> badges;
  final String routeSummary;

  bool get isMatch =>
      compatibilityType != RouteCompatibilityType.incompatible &&
      !isBlockedByRestrictions;
}
