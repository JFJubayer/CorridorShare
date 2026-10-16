import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/matching/domain/entities/match_check.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';

class FindParcelsForTrip {
  const FindParcelsForTrip(this._parcelRepository);

  final ParcelRepository _parcelRepository;

  Future<Result<List<Parcel>>> call(Trip trip) async {
    final result = await _parcelRepository.getParcels(
      fromDistrict: trip.fromDistrict,
      toDistrict: trip.toDistrict,
    );

    return result.fold(
      (parcels) {
        final matches = parcels.where((parcel) {
          if (parcel.status != ParcelStatus.open) return false;
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

        return Ok<List<Parcel>>(matches);
      },
      (failure) => Err<List<Parcel>>(failure),
    );
  }
}
