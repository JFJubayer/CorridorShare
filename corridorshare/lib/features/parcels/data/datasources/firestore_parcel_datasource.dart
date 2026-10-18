import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/firebase/firestore_rest_service.dart';
import 'package:corridorshare/features/parcels/data/datasources/parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreParcelDataSource implements ParcelDataSource {
  FirestoreParcelDataSource({
    this.firestore,
    FirestoreRestService? restService,
  }) : _restService = restService ?? FirestoreRestService.instance;

  final FirebaseFirestore? firestore;
  final FirestoreRestService _restService;

  bool get _useNativeFirestore =>
      firestore != null || Firebase.apps.isNotEmpty;

  CollectionReference<Map<String, dynamic>> get _collection =>
      (firestore ?? FirebaseFirestore.instance).collection('parcels');

  @override
  Future<ParcelDto> createParcel(ParcelDto parcel) async {
    try {
      final docId = parcel.id.isNotEmpty
          ? parcel.id
          : 'parcel_${DateTime.now().millisecondsSinceEpoch}';
      final item = parcel.copyWith(id: docId);

      if (_useNativeFirestore) {
        await _collection.doc(docId).set(item.toJson());
      } else {
        await _restService.setDocument('parcels', docId, item.toJson());
      }
      return item;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to create parcel: $e');
    }
  }

  @override
  Future<List<ParcelDto>> getParcels({
    String? fromDistrict,
    String? toDistrict,
  }) async {
    try {
      List<ParcelDto> allParcels;

      if (_useNativeFirestore) {
        final snapshot = await _collection.get();
        allParcels = snapshot.docs.map((doc) {
          final data = doc.data();
          final map = Map<String, dynamic>.from(data);
          map['id'] = doc.id;
          return ParcelDto.fromJson(map);
        }).toList();
      } else {
        final docs = await _restService.getDocuments('parcels');
        allParcels = docs.map((map) => ParcelDto.fromJson(map)).toList();
      }

      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      // Filter and display ONLY AVAILABLE data
      final availableParcels = allParcels.where((p) {
        // 1. Status must be available (open)
        if (p.status.toLowerCase() != 'open') {
          return false;
        }

        // 2. Deadline must not be in the past
        final deadlineDate = DateTime.tryParse(p.deadline);
        if (deadlineDate != null) {
          final deadlineMidnight =
              DateTime(deadlineDate.year, deadlineDate.month, deadlineDate.day);
          if (deadlineMidnight.isBefore(todayMidnight)) {
            return false;
          }
        }

        // 3. District filters if requested
        if (fromDistrict != null &&
            fromDistrict.isNotEmpty &&
            p.fromDistrict.toLowerCase() != fromDistrict.toLowerCase()) {
          return false;
        }
        if (toDistrict != null &&
            toDistrict.isNotEmpty &&
            p.toDistrict.toLowerCase() != toDistrict.toLowerCase()) {
          return false;
        }

        return true;
      }).toList();

      availableParcels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return availableParcels;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch parcels: $e');
    }
  }

  @override
  Future<List<ParcelDto>> getMyParcels(String senderId) async {
    try {
      List<ParcelDto> parcels;

      if (_useNativeFirestore) {
        final snapshot =
            await _collection.where('senderId', isEqualTo: senderId).get();
        parcels = snapshot.docs.map((doc) {
          final data = doc.data();
          final map = Map<String, dynamic>.from(data);
          map['id'] = doc.id;
          return ParcelDto.fromJson(map);
        }).toList();
      } else {
        final docs = await _restService.getDocuments('parcels');
        parcels = docs
            .map((map) => ParcelDto.fromJson(map))
            .where((p) => p.senderId == senderId)
            .toList();
      }

      parcels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return parcels;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch my parcels: $e');
    }
  }

  @override
  Future<ParcelDto> getParcelById(String id) async {
    try {
      if (_useNativeFirestore) {
        final doc = await _collection.doc(id).get();
        if (!doc.exists || doc.data() == null) {
          throw const NotFoundFailure('Parcel not found');
        }
        final map = Map<String, dynamic>.from(doc.data()!);
        map['id'] = doc.id;
        return ParcelDto.fromJson(map);
      } else {
        final map = await _restService.getDocument('parcels', id);
        if (map == null) {
          throw const NotFoundFailure('Parcel not found');
        }
        return ParcelDto.fromJson(map);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch parcel: $e');
    }
  }

  @override
  Future<ParcelDto> updateParcelStatus({
    required String id,
    required String status,
  }) async {
    try {
      if (_useNativeFirestore) {
        final docRef = _collection.doc(id);
        final doc = await docRef.get();
        if (!doc.exists || doc.data() == null) {
          throw const NotFoundFailure('Parcel not found');
        }
        await docRef.update({'status': status});
        final map = Map<String, dynamic>.from(doc.data()!);
        map['id'] = doc.id;
        map['status'] = status;
        return ParcelDto.fromJson(map);
      } else {
        final existing = await _restService.getDocument('parcels', id);
        if (existing == null) {
          throw const NotFoundFailure('Parcel not found');
        }
        await _restService.updateDocument('parcels', id, {'status': status});
        existing['status'] = status;
        return ParcelDto.fromJson(existing);
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to update parcel status: $e');
    }
  }
}
