import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/matching/domain/services/route_match_engine.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';

class FindParcelsForTrip {
  const FindParcelsForTrip(this._parcelRepository);

  final ParcelRepository _parcelRepository;

  Future<Result<List<Parcel>>> call(Trip trip) async {
    // 1. Fetch available parcels (corridor wide or fallback to districts)
    var result = await _parcelRepository.getParcels();

    var parcels = result.fold(
      (p) => p,
      (_) => <Parcel>[],
    );

    if (parcels.isEmpty) {
      final districtResult = await _parcelRepository.getParcels(
        fromDistrict: trip.fromDistrict,
        toDistrict: trip.toDistrict,
      );
      parcels = districtResult.fold(
        (p) => p,
        (_) => <Parcel>[],
      );
    }

    if (parcels.isEmpty) {
      return const Ok<List<Parcel>>(<Parcel>[]);
    }

    // 2. Run RouteMatchEngine across the travel corridor
    final matchResults = RouteMatchEngine.autoMatchParcelsForTrip(
      trip: trip,
      allParcels: parcels,
    );

    final matchingParcels = matchResults
        .where((r) => r.isMatch)
        .map((r) => r.parcel)
        .toList();

    return Ok<List<Parcel>>(matchingParcels);
  }
}
