import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/features/parcels/data/datasources/parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';

class FirestoreParcelDataSource implements ParcelDataSource {
  FirestoreParcelDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('parcels');

  @override
  Future<ParcelDto> createParcel(ParcelDto parcel) async {
    try {
      final docRef = parcel.id.isNotEmpty
          ? _collection.doc(parcel.id)
          : _collection.doc();
      final item =
          parcel.id.isNotEmpty ? parcel : parcel.copyWith(id: docRef.id);
      await docRef.set(item.toJson());
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
      final snapshot = await _collection.get();
      final parcels = snapshot.docs.map((doc) {
        final data = doc.data();
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        return ParcelDto.fromJson(map);
      }).where((p) {
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

      parcels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return parcels;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch parcels: $e');
    }
  }

  @override
  Future<List<ParcelDto>> getMyParcels(String senderId) async {
    try {
      final snapshot =
          await _collection.where('senderId', isEqualTo: senderId).get();
      final parcels = snapshot.docs.map((doc) {
        final data = doc.data();
        final map = Map<String, dynamic>.from(data);
        map['id'] = doc.id;
        return ParcelDto.fromJson(map);
      }).toList();

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
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw const NotFoundFailure('Parcel not found');
      }
      final map = Map<String, dynamic>.from(doc.data()!);
      map['id'] = doc.id;
      return ParcelDto.fromJson(map);
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
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to update parcel status: $e');
    }
  }
}
