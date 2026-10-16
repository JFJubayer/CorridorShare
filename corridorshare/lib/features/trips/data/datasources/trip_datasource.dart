import 'package:corridorshare/features/trips/data/models/trip_dto.dart';

abstract class TripDataSource {
  Future<TripDto> createTrip(TripDto trip);

  Future<List<TripDto>> getTrips({
    String? fromDistrict,
    String? toDistrict,
    String? date,
  });

  Future<List<TripDto>> getMyTrips(String travellerId);

  Future<TripDto> getTripById(String id);

  Future<TripDto> updateTripStatus({
    required String id,
    required String status,
  });
}
