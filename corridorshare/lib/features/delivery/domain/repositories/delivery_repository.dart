import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';

abstract class DeliveryRepository {
  Future<Result<Delivery>> getDeliveryById(String id);

  Future<Result<Delivery>> getDeliveryByParcelId(String parcelId);

  Future<Result<List<Delivery>>> getDeliveriesForUser(String userId);

  Future<Result<Delivery>> createDelivery(Delivery delivery);

  Future<Result<Delivery>> confirmPickup({
    required String deliveryId,
    required String photoUrl,
    String? notes,
  });

  Future<Result<Delivery>> verifyDelivery({
    required String deliveryId,
    required String inputPin,
    String? photoUrl,
  });

  Future<Result<Delivery>> reportDispute({
    required String deliveryId,
    required String reason,
    required String reporterId,
  });
}
