import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';

abstract class ParcelRepository {
  /// Create a new parcel posting.
  Future<Result<Parcel>> createParcel(Parcel parcel);

  /// Fetch parcels with optional district filters.
  Future<Result<List<Parcel>>> getParcels({
    String? fromDistrict,
    String? toDistrict,
  });

  /// Fetch parcels posted by a specific sender.
  Future<Result<List<Parcel>>> getMyParcels(String senderId);

  /// Fetch a parcel by id.
  Future<Result<Parcel>> getParcelById(String id);

  /// Update the status of a parcel.
  Future<Result<Parcel>> updateParcelStatus({
    required String id,
    required ParcelStatus status,
  });
}
