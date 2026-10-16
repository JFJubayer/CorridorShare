import 'package:corridorshare/core/constants/bangladesh_districts.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/repositories/trip_repository.dart';

class CreateTrip {
  const CreateTrip(this._repository);

  final TripRepository _repository;

  Future<Result<Trip>> call(Trip trip) async {
    if (trip.travellerId.trim().isEmpty) {
      return const Err<Trip>(
        ValidationFailure('Traveller ID is required'),
      );
    }
    if (!BangladeshDistricts.isValid(trip.fromDistrict)) {
      return Err<Trip>(
        ValidationFailure('Invalid origin district: ${trip.fromDistrict}'),
      );
    }
    if (!BangladeshDistricts.isValid(trip.toDistrict)) {
      return Err<Trip>(
        ValidationFailure('Invalid destination district: ${trip.toDistrict}'),
      );
    }
    if (trip.fromDistrict.toLowerCase() == trip.toDistrict.toLowerCase()) {
      return const Err<Trip>(
        ValidationFailure('Origin and destination districts cannot be the same'),
      );
    }
    if (trip.capacityKg <= 0) {
      return const Err<Trip>(
        ValidationFailure('Capacity must be greater than 0 kg'),
      );
    }
    if (trip.capacityKg > 50) {
      return const Err<Trip>(
        ValidationFailure('Capacity cannot exceed 50 kg for crowd-shipping'),
      );
    }
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final depMidnight = DateTime(
      trip.departureDate.year,
      trip.departureDate.month,
      trip.departureDate.day,
    );
    if (depMidnight.isBefore(todayMidnight)) {
      return const Err<Trip>(
        ValidationFailure('Departure date cannot be in the past'),
      );
    }

    return _repository.createTrip(trip);
  }
}
