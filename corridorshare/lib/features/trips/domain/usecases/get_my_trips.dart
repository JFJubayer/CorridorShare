import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/repositories/trip_repository.dart';

class GetMyTrips {
  const GetMyTrips(this._repository);

  final TripRepository _repository;

  Future<Result<List<Trip>>> call(String travellerId) {
    return _repository.getMyTrips(travellerId);
  }
}
