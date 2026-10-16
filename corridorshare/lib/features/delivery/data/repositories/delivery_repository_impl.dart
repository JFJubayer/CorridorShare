import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/delivery/data/datasources/delivery_datasource.dart';
import 'package:corridorshare/features/delivery/data/models/delivery_dto.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/domain/repositories/delivery_repository.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  const DeliveryRepositoryImpl(this._dataSource);

  final DeliveryDataSource _dataSource;

  @override
  Future<Result<Delivery>> getDeliveryById(String id) async {
    try {
      final dto = await _dataSource.getDeliveryById(id);
      return Ok<Delivery>(dto.toDomain());
    } on Failure catch (f) {
      return Err<Delivery>(f);
    } catch (e) {
      return Err<Delivery>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Delivery>> getDeliveryByParcelId(String parcelId) async {
    try {
      final dto = await _dataSource.getDeliveryByParcelId(parcelId);
      return Ok<Delivery>(dto.toDomain());
    } on Failure catch (f) {
      return Err<Delivery>(f);
    } catch (e) {
      return Err<Delivery>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Delivery>>> getDeliveriesForUser(String userId) async {
    try {
      final dtos = await _dataSource.getDeliveriesForUser(userId);
      return Ok<List<Delivery>>(dtos.map((d) => d.toDomain()).toList());
    } on Failure catch (f) {
      return Err<List<Delivery>>(f);
    } catch (e) {
      return Err<List<Delivery>>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Delivery>> createDelivery(Delivery delivery) async {
    try {
      final dto = DeliveryDto.fromDomain(delivery);
      final created = await _dataSource.createDelivery(dto);
      return Ok<Delivery>(created.toDomain());
    } on Failure catch (f) {
      return Err<Delivery>(f);
    } catch (e) {
      return Err<Delivery>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Delivery>> confirmPickup({
    required String deliveryId,
    required String photoUrl,
    String? notes,
  }) async {
    try {
      final updated = await _dataSource.confirmPickup(
        deliveryId: deliveryId,
        photoUrl: photoUrl,
        notes: notes,
      );
      return Ok<Delivery>(updated.toDomain());
    } on Failure catch (f) {
      return Err<Delivery>(f);
    } catch (e) {
      return Err<Delivery>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Delivery>> verifyDelivery({
    required String deliveryId,
    required String inputPin,
    String? photoUrl,
  }) async {
    try {
      final updated = await _dataSource.verifyDelivery(
        deliveryId: deliveryId,
        inputPin: inputPin,
        photoUrl: photoUrl,
      );
      return Ok<Delivery>(updated.toDomain());
    } on Failure catch (f) {
      return Err<Delivery>(f);
    } catch (e) {
      return Err<Delivery>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Delivery>> reportDispute({
    required String deliveryId,
    required String reason,
    required String reporterId,
  }) async {
    try {
      final updated = await _dataSource.reportDispute(
        deliveryId: deliveryId,
        reason: reason,
        reporterId: reporterId,
      );
      return Ok<Delivery>(updated.toDomain());
    } on Failure catch (f) {
      return Err<Delivery>(f);
    } catch (e) {
      return Err<Delivery>(ServerFailure(e.toString()));
    }
  }
}
