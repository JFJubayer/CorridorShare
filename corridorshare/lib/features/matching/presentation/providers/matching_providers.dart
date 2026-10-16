import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/matching/domain/usecases/find_parcels_for_trip.dart';
import 'package:corridorshare/features/matching/domain/usecases/find_trips_for_parcel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final findParcelsForTripUseCaseProvider = Provider<FindParcelsForTrip>((ref) {
  return FindParcelsForTrip(ref.watch(parcelRepositoryProvider));
});

final findTripsForParcelUseCaseProvider = Provider<FindTripsForParcel>((ref) {
  return FindTripsForParcel(ref.watch(tripRepositoryProvider));
});
