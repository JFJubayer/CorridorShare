import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/admin/data/datasources/admin_datasource.dart';
import 'package:corridorshare/features/admin/domain/entities/platform_metrics.dart';
import 'package:corridorshare/features/admin/domain/repositories/admin_repository.dart';
import 'package:corridorshare/features/delivery/data/models/delivery_dto.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._dataSource);

  final AdminDataSource _dataSource;

  @override
  Future<Result<PlatformMetrics>> getPlatformMetrics() async {
    try {
      final metrics = await _dataSource.getPlatformMetrics();
      return Ok<PlatformMetrics>(metrics);
    } on Failure catch (f) {
      return Err<PlatformMetrics>(f);
    } catch (e) {
      return Err<PlatformMetrics>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Delivery>>> getDisputedDeliveries() async {
    try {
      final dtos = await _dataSource.getDisputedDeliveries();
      return Ok<List<Delivery>>(dtos.map((d) => d.toDomain()).toList());
    } on Failure catch (f) {
      return Err<List<Delivery>>(f);
    } catch (e) {
      return Err<List<Delivery>>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<Delivery>> resolveDispute({
    required String deliveryId,
    required DisputeResolution resolution,
    required String adminNotes,
  }) async {
    try {
      final dto = await _dataSource.resolveDispute(
        deliveryId: deliveryId,
        resolution: resolution,
        adminNotes: adminNotes,
      );
      return Ok<Delivery>(dto.toDomain());
    } on Failure catch (f) {
      return Err<Delivery>(f);
    } catch (e) {
      return Err<Delivery>(ServerFailure(e.toString()));
    }
  }
}
