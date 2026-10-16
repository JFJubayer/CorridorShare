import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';

class GetParcels {
  const GetParcels(this._repository);

  final ParcelRepository _repository;

  Future<Result<List<Parcel>>> call({
    String? fromDistrict,
    String? toDistrict,
  }) {
    return _repository.getParcels(
      fromDistrict: fromDistrict,
      toDistrict: toDistrict,
    );
  }
}
