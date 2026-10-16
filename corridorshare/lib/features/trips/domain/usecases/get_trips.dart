import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/repositories/trip_repository.dart';

class GetTrips {
  const GetTrips(this._repository);

  final TripRepository _repository;

  Future<Result<List<Trip>>> call({
    String? fromDistrict,
    String? toDistrict,
    DateTime? date,
  }) {
    return _repository.getTrips(
      fromDistrict: fromDistrict,
      toDistrict: toDistrict,
      date: date,
    );
  }
}
