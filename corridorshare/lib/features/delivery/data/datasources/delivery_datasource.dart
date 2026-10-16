import 'package:corridorshare/features/delivery/data/models/delivery_dto.dart';

abstract class DeliveryDataSource {
  Future<DeliveryDto> getDeliveryById(String id);

  Future<DeliveryDto> getDeliveryByParcelId(String parcelId);

  Future<List<DeliveryDto>> getDeliveriesForUser(String userId);

  Future<List<DeliveryDto>> getAllDeliveries();

  Future<DeliveryDto> createDelivery(DeliveryDto delivery);

  Future<DeliveryDto> confirmPickup({
    required String deliveryId,
    required String photoUrl,
    String? notes,
  });

  Future<DeliveryDto> verifyDelivery({
    required String deliveryId,
    required String inputPin,
    String? photoUrl,
  });

  Future<DeliveryDto> reportDispute({
    required String deliveryId,
    required String reason,
    required String reporterId,
  });
}
