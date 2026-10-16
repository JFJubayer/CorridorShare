import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/features/trips/data/datasources/trip_datasource.dart';
import 'package:corridorshare/features/trips/data/models/trip_dto.dart';

class InMemoryTripDataSource implements TripDataSource {
  InMemoryTripDataSource({List<TripDto>? initialTrips, bool seed = false})
      : _trips = initialTrips != null
            ? List<TripDto>.from(initialTrips)
            : (seed ? _seedTrips() : <TripDto>[]);

  final List<TripDto> _trips;

  static List<TripDto> _seedTrips() {
    final now = DateTime.now();
    return <TripDto>[
      TripDto(
        id: 'trip-1',
        travellerId: 'traveller-1',
        travellerName: 'Rafiqul Islam',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara Sector 7',
        toDistrict: 'Chattogram',
        toArea: 'GEC Circle',
        departureDate: now.add(const Duration(days: 2)).toIso8601String(),
        capacityKg: 8.5,
        noCarryTags: const <String>['liquid', 'perishable_food'],
        note: 'Travelling by Sonar Bangla Express train. Can carry documents or gadgets.',
        status: 'open',
        createdAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
      ),
    ];
  }

  @override
  Future<TripDto> createTrip(TripDto trip) async {
    _trips.insert(0, trip);
    return trip;
  }

  @override
  Future<List<TripDto>> getTrips({
    String? fromDistrict,
    String? toDistrict,
    String? date,
  }) async {
    return _trips.where((t) {
      if (fromDistrict != null &&
          fromDistrict.isNotEmpty &&
          t.fromDistrict.toLowerCase() != fromDistrict.toLowerCase()) {
        return false;
      }
      if (toDistrict != null &&
          toDistrict.isNotEmpty &&
          t.toDistrict.toLowerCase() != toDistrict.toLowerCase()) {
        return false;
      }
      if (date != null && date.isNotEmpty) {
        final queryDate = DateTime.parse(date);
        final tripDate = DateTime.parse(t.departureDate);
        if (queryDate.year != tripDate.year ||
            queryDate.month != tripDate.month ||
            queryDate.day != tripDate.day) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<List<TripDto>> getMyTrips(String travellerId) async {
    return _trips.where((t) => t.travellerId == travellerId).toList();
  }

  @override
  Future<TripDto> getTripById(String id) async {
    final index = _trips.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw const NotFoundFailure('Trip not found');
    }
    return _trips[index];
  }

  @override
  Future<TripDto> updateTripStatus({
    required String id,
    required String status,
  }) async {
    final index = _trips.indexWhere((t) => t.id == id);
    if (index == -1) {
      throw const NotFoundFailure('Trip not found');
    }
    final updated = _trips[index].copyWith(status: status);
    _trips[index] = updated;
    return updated;
  }
}
