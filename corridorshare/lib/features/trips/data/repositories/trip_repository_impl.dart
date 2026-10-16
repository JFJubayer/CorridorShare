import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/trips/data/datasources/trip_datasource.dart';
import 'package:corridorshare/features/trips/data/models/trip_dto.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:corridorshare/features/trips/domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  const TripRepositoryImpl(this._dataSource);

  final TripDataSource _dataSource;

  @override
  Future<Result<Trip>> createTrip(Trip trip) async {
    try {
      final dto = TripDto.fromDomain(trip);
      final created = await _dataSource.createTrip(dto);
      return Ok<Trip>(created.toDomain());
    } on Failure catch (f) {
      return Err<Trip>(f);
    } catch (e) {
      return Err<Trip>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Trip>>> getTrips({
    String? fromDistrict,
    String? toDistrict,
    DateTime? date,
  }) async {
    try {
      final dtos = await _dataSource.getTrips(
        fromDistrict: fromDistrict,
        toDistrict: toDistrict,
        date: date?.toIso8601String(),
      );
      return Ok<List<Trip>>(
        dtos.map((dto) => dto.toDomain()).toList(),
      );
    } on Failure catch (f) {
      return Err<List<Trip>>(f);
    } catch (e) {
      return Err<List<Trip>>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Trip>>> getMyTrips(String travellerId) async {
    try {
      final dtos = await _dataSource.getMyTrips(travellerId);
      return Ok<List<Trip>>(
        dtos.map((dto) => dto.toDomain()).toList(),
      );
    } on Failure catch (f) {
      return Err<List<Trip>>(f);
    } catch (e) {
      return Err<List<Trip>>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Trip>> getTripById(String id) async {
    try {
      final dto = await _dataSource.getTripById(id);
      return Ok<Trip>(dto.toDomain());
    } on Failure catch (f) {
      return Err<Trip>(f);
    } catch (e) {
      return Err<Trip>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Trip>> updateTripStatus({
    required String id,
    required TripStatus status,
  }) async {
    try {
      final updated = await _dataSource.updateTripStatus(
        id: id,
        status: status.name,
      );
      return Ok<Trip>(updated.toDomain());
    } on Failure catch (f) {
      return Err<Trip>(f);
    } catch (e) {
      return Err<Trip>(UnknownFailure(e.toString()));
    }
  }
}
