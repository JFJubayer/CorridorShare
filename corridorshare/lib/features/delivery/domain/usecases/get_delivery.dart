import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/domain/repositories/delivery_repository.dart';

class GetDelivery {
  const GetDelivery(this._repository);

  final DeliveryRepository _repository;

  Future<Result<Delivery>> byId(String id) {
    return _repository.getDeliveryById(id);
  }

  Future<Result<Delivery>> byParcelId(String parcelId) {
    return _repository.getDeliveryByParcelId(parcelId);
  }

  Future<Result<List<Delivery>>> forUser(String userId) {
    return _repository.getDeliveriesForUser(userId);
  }
}
