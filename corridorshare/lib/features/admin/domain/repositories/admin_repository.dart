import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/admin/domain/entities/platform_metrics.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';

abstract class AdminRepository {
  Future<Result<PlatformMetrics>> getPlatformMetrics();

  Future<Result<List<Delivery>>> getDisputedDeliveries();

  Future<Result<Delivery>> resolveDispute({
    required String deliveryId,
    required DisputeResolution resolution,
    required String adminNotes,
  });
}
