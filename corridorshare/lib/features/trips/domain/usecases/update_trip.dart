import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/repositories/trip_repository.dart';

class UpdateTrip {
  const UpdateTrip(this._repository);

  final TripRepository _repository;

  Future<Result<Trip>> call(Trip trip) => _repository.updateTrip(trip);
}
