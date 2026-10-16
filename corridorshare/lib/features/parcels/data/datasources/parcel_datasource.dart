import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';

abstract class ParcelDataSource {
  Future<ParcelDto> createParcel(ParcelDto parcel);

  Future<List<ParcelDto>> getParcels({
    String? fromDistrict,
    String? toDistrict,
  });

  Future<List<ParcelDto>> getMyParcels(String senderId);

  Future<ParcelDto> getParcelById(String id);

  Future<ParcelDto> updateParcelStatus({
    required String id,
    required String status,
  });
}
