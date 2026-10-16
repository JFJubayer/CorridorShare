import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/parcels/data/datasources/parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';

class ParcelRepositoryImpl implements ParcelRepository {
  const ParcelRepositoryImpl(this._dataSource);

  final ParcelDataSource _dataSource;

  @override
  Future<Result<Parcel>> createParcel(Parcel parcel) async {
    try {
      final dto = ParcelDto.fromDomain(parcel);
      final created = await _dataSource.createParcel(dto);
      return Ok<Parcel>(created.toDomain());
    } on Failure catch (f) {
      return Err<Parcel>(f);
    } catch (e) {
      return Err<Parcel>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Parcel>>> getParcels({
    String? fromDistrict,
    String? toDistrict,
  }) async {
    try {
      final dtos = await _dataSource.getParcels(
        fromDistrict: fromDistrict,
        toDistrict: toDistrict,
      );
      return Ok<List<Parcel>>(
        dtos.map((dto) => dto.toDomain()).toList(),
      );
    } on Failure catch (f) {
      return Err<List<Parcel>>(f);
    } catch (e) {
      return Err<List<Parcel>>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Parcel>>> getMyParcels(String senderId) async {
    try {
      final dtos = await _dataSource.getMyParcels(senderId);
      return Ok<List<Parcel>>(
        dtos.map((dto) => dto.toDomain()).toList(),
      );
    } on Failure catch (f) {
      return Err<List<Parcel>>(f);
    } catch (e) {
      return Err<List<Parcel>>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Parcel>> getParcelById(String id) async {
    try {
      final dto = await _dataSource.getParcelById(id);
      return Ok<Parcel>(dto.toDomain());
    } on Failure catch (f) {
      return Err<Parcel>(f);
    } catch (e) {
      return Err<Parcel>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Parcel>> updateParcelStatus({
    required String id,
    required ParcelStatus status,
  }) async {
    try {
      final updated = await _dataSource.updateParcelStatus(
        id: id,
        status: status.name,
      );
      return Ok<Parcel>(updated.toDomain());
    } on Failure catch (f) {
      return Err<Parcel>(f);
    } catch (e) {
      return Err<Parcel>(UnknownFailure(e.toString()));
    }
  }
}
