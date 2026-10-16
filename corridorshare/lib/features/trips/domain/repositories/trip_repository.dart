import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';

abstract class TripRepository {
  /// Create a new trip.
  Future<Result<Trip>> createTrip(Trip trip);

  /// Fetch trips with optional district and date filters.
  Future<Result<List<Trip>>> getTrips({
    String? fromDistrict,
    String? toDistrict,
    DateTime? date,
  });

  /// Fetch trips posted by a specific traveller.
  Future<Result<List<Trip>>> getMyTrips(String travellerId);

  /// Fetch a trip by id.
  Future<Result<Trip>> getTripById(String id);

  /// Update the status of a trip.
  Future<Result<Trip>> updateTripStatus({
    required String id,
    required TripStatus status,
  });
}
