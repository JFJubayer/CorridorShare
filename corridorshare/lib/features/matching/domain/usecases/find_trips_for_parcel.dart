import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/matching/domain/entities/match_check.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:corridorshare/features/trips/domain/repositories/trip_repository.dart';

class FindTripsForParcel {
  const FindTripsForParcel(this._tripRepository);

  final TripRepository _tripRepository;

  Future<Result<List<Trip>>> call(Parcel parcel) async {
    final result = await _tripRepository.getTrips(
      fromDistrict: parcel.fromDistrict,
      toDistrict: parcel.toDistrict,
    );

    return result.fold(
      (trips) {
        final matches = trips.where((trip) {
          if (trip.status != TripStatus.open) return false;
          if (!MatchCheck.isRouteCompatible(trip: trip, parcel: parcel)) {
            return false;
          }
          if (!MatchCheck.isDateCompatible(trip: trip, parcel: parcel)) {
            return false;
          }
          if (!MatchCheck.isCapacityCompatible(trip: trip, parcel: parcel)) {
            return false;
          }
          if (MatchCheck.isBlockedByNoCarry(trip: trip, parcel: parcel)) {
            return false;
          }
          return true;
        }).toList();

        return Ok<List<Trip>>(matches);
      },
      (failure) => Err<List<Trip>>(failure),
    );
  }
}
