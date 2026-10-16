import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';

class GetMyParcels {
  const GetMyParcels(this._repository);

  final ParcelRepository _repository;

  Future<Result<List<Parcel>>> call(String senderId) {
    return _repository.getMyParcels(senderId);
  }
}
