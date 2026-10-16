import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:corridorshare/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';

class ConfirmPickup {
  const ConfirmPickup(this._deliveryRepository, this._parcelRepository);

  final DeliveryRepository _deliveryRepository;
  final ParcelRepository _parcelRepository;

  Future<Result<Delivery>> call({
    required String deliveryId,
    required String photoUrl,
    String? notes,
  }) async {
    if (photoUrl.trim().isEmpty) {
      return const Err<Delivery>(
        ValidationFailure('Pickup handover photo proof is required'),
      );
    }

    final deliveryRes = await _deliveryRepository.getDeliveryById(deliveryId);
    return deliveryRes.fold(
      (delivery) async {
        if (delivery.status != DeliveryStatus.matched) {
          return const Err<Delivery>(
            ValidationFailure('Only matched deliveries can be picked up'),
          );
        }

        final updateRes = await _deliveryRepository.confirmPickup(
          deliveryId: deliveryId,
          photoUrl: photoUrl.trim(),
          notes: notes?.trim(),
        );

        return updateRes.fold(
          (updatedDelivery) async {
            // Transition underlying parcel to inTransit
            await _parcelRepository.updateParcelStatus(
              id: updatedDelivery.parcelId,
              status: ParcelStatus.inTransit,
            );
            return Ok<Delivery>(updatedDelivery);
          },
          (failure) => Err<Delivery>(failure),
        );
      },
      (failure) => Err<Delivery>(failure),
    );
  }
}
