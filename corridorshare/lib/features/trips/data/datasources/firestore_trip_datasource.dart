import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/firebase/firestore_rest_service.dart';
import 'package:corridorshare/features/trips/data/datasources/trip_datasource.dart';
import 'package:corridorshare/features/trips/data/models/trip_dto.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreTripDataSource implements TripDataSource {
  FirestoreTripDataSource({
    this.firestore,
    FirestoreRestService? restService,
  }) : _restService = restService ?? FirestoreRestService.instance;

  final FirebaseFirestore? firestore;
  final FirestoreRestService _restService;

  bool get _useNativeFirestore =>
      firestore != null || Firebase.apps.isNotEmpty;

  CollectionReference<Map<String, dynamic>> get _collection =>
      (firestore ?? FirebaseFirestore.instance).collection('trips');

  @override
  Future<TripDto> createTrip(TripDto trip) async {
    try {
      final docId = trip.id.isNotEmpty
          ? trip.id
          : 'trip_${DateTime.now().millisecondsSinceEpoch}';
      final item = trip.copyWith(id: docId);

      if (_useNativeFirestore) {
        await _collection.doc(docId).set(item.toJson());
      } else {
        await _restService.setDocument('trips', docId, item.toJson());
      }
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
      List<TripDto> allTrips;

      if (_useNativeFirestore) {
        final snapshot = await _collection.get();
        allTrips = snapshot.docs.map((doc) {
          final data = doc.data();
          final map = Map<String, dynamic>.from(data);
          map['id'] = doc.id;
          return TripDto.fromJson(map);
        }).toList();
      } else {
        final docs = await _restService.getDocuments('trips');
        allTrips = docs.map((map) => TripDto.fromJson(map)).toList();
      }

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      // Filter and display ONLY AVAILABLE data
      final availableTrips = allTrips.where((t) {
        // 1. Status must be available (open)
        if (t.status.toLowerCase() != 'open') {
          return false;
        }

        // 2. Capacity must be greater than zero
        if (t.capacityKg <= 0) {
          return false;
        }

        // 3. Trip departure date must not be in the past
        final tripDate = DateTime.tryParse(t.departureDate);
        if (tripDate != null) {
          final tripMidnight =
              DateTime(tripDate.year, tripDate.month, tripDate.day);
          if (tripMidnight.isBefore(todayMidnight)) {
            return false;
          }
        }

        // 4. District filters if requested
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

        // 5. Specific date filter if requested
        if (date != null && date.isNotEmpty) {
          final queryDate = DateTime.tryParse(date);
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

      availableTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return availableTrips;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch trips: $e');
    }
  }

  @override
  Future<List<TripDto>> getMyTrips(String travellerId) async {
    try {
      List<TripDto> trips;

      if (_useNativeFirestore) {
        final snapshot =
            await _collection.where('travellerId', isEqualTo: travellerId).get();
        trips = snapshot.docs.map((doc) {
          final data = doc.data();
          final map = Map<String, dynamic>.from(data);
          map['id'] = doc.id;
          return TripDto.fromJson(map);
        }).toList();
      } else {
        final docs = await _restService.getDocuments('trips');
        trips = docs
            .map((map) => TripDto.fromJson(map))
            .where((t) => t.travellerId == travellerId)
            .toList();
      }

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
      if (_useNativeFirestore) {
        final doc = await _collection.doc(id).get();
        if (!doc.exists || doc.data() == null) {
          throw const NotFoundFailure('Trip not found');
        }
        final map = Map<String, dynamic>.from(doc.data()!);
        map['id'] = doc.id;
        return TripDto.fromJson(map);
      } else {
        final map = await _restService.getDocument('trips', id);
        if (map == null) {
          throw const NotFoundFailure('Trip not found');
        }
        return TripDto.fromJson(map);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch trip: $e');
    }
  }

  @override
  Future<TripDto> updateTrip(TripDto trip) async {
    try {
      if (_useNativeFirestore) {
        await _collection.doc(trip.id).set(trip.toJson(), SetOptions(merge: true));
      } else {
        await _restService.setDocument('trips', trip.id, trip.toJson());
      }
      return trip;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to update trip: $e');
    }
  }

  @override
  Future<TripDto> updateTripStatus({
    required String id,
    required String status,
  }) async {
    try {
      if (_useNativeFirestore) {
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
      } else {
        final existing = await _restService.getDocument('trips', id);
        if (existing == null) {
          throw const NotFoundFailure('Trip not found');
        }
        await _restService.updateDocument('trips', id, {'status': status});
        existing['status'] = status;
        return TripDto.fromJson(existing);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to update trip status: $e');
    }
  }
}
