import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/features/trips/data/datasources/trip_datasource.dart';
import 'package:corridorshare/features/trips/data/models/trip_dto.dart';

class FirestoreTripDataSource implements TripDataSource {
  FirestoreTripDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('trips');

  @override
  Future<TripDto> createTrip(TripDto trip) async {
    try {
      final docRef = trip.id.isNotEmpty
          ? _collection.doc(trip.id)
          : _collection.doc();
      final item = trip.id.isNotEmpty ? trip : trip.copyWith(id: docRef.id);
      await docRef.set(item.toJson());
      return item;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to create trip: $e');
    }
  }

  @override
  Future<List<TripDto>> getTrips({
    String? fromDistrict,
    String? toDistrict,
    String? date,
  }) async {
    try {
      final snapshot = await _collection.get();
      final trips = snapshot.docs.map((doc) {
        final data = doc.data();
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        return TripDto.fromJson(map);
      }).where((t) {
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
          final queryDate = DateTime.tryParse(date);
          final tripDate = DateTime.tryParse(t.departureDate);
          if (queryDate != null && tripDate != null) {
            if (queryDate.year != tripDate.year ||
                queryDate.month != tripDate.month ||
                queryDate.day != tripDate.day) {
              return false;
            }
          }
        }
        return true;
      }).toList();

      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch trips: $e');
    }
  }

  @override
  Future<List<TripDto>> getMyTrips(String travellerId) async {
    try {
      final snapshot =
          await _collection.where('travellerId', isEqualTo: travellerId).get();
      final trips = snapshot.docs.map((doc) {
        final data = doc.data();
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        return TripDto.fromJson(map);
      }).toList();

      trips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return trips;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch my trips: $e');
    }
  }

  @override
  Future<TripDto> getTripById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundFailure('Trip not found');
      }
      final map = Map<String, dynamic>.from(doc.data()!);
      map['id'] = doc.id;
      return TripDto.fromJson(map);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch trip: $e');
    }
  }

  @override
  Future<TripDto> updateTripStatus({
    required String id,
    required String status,
  }) async {
    try {
      final docRef = _collection.doc(id);
      final doc = await docRef.get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundFailure('Trip not found');
      }
      await docRef.update({'status': status});
      final map = Map<String, dynamic>.from(doc.data()!);
      map['id'] = doc.id;
      map['status'] = status;
      return TripDto.fromJson(map);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to update trip status: $e');
    }
  }
}
