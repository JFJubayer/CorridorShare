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
        id: 'trip-mymensingh',
        travellerId: 'fake-uid-test',
        travellerName: 'Tanvir Ahmed',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara',
        toDistrict: 'Mymensingh',
        toArea: 'Mymensingh Sadar',
        departureDate: DateTime(2026, 10, 24, 9, 0).toIso8601String(),
        capacityKg: 5.0,
        bookedKg: 2.2,
        matchingParcelsCount: 4,
        noCarryTags: const <String>['liquids', 'fragile'],
        note: 'Travelling by car. Can carry documents and books.',
        status: 'open',
        createdAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
      ),
      TripDto(
        id: 'trip-sylhet',
        travellerId: 'fake-uid-test',
        travellerName: 'Tanvir Ahmed',
        fromDistrict: 'Dhaka',
        fromArea: 'Mohakhali',
        toDistrict: 'Sylhet',
        toArea: 'Zindabazar',
        departureDate: DateTime(2026, 10, 25, 7, 30).toIso8601String(),
        capacityKg: 4.0,
        bookedKg: 0.0,
        matchingParcelsCount: 0,
        noCarryTags: const <String>['electronics'],
        note: 'Travelling by Parabat Express.',
        status: 'open',
        createdAt: now.subtract(const Duration(hours: 6)).toIso8601String(),
      ),
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
        bookedKg: 0.0,
        matchingParcelsCount: 2,
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
  Future<TripDto> updateTrip(TripDto trip) async {
    final index = _trips.indexWhere((t) => t.id == trip.id);
    if (index == -1) {
      _trips.insert(0, trip);
    } else {
      _trips[index] = trip;
    }
    return trip;
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
