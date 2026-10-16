import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:corridorshare/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';

class VerifyDelivery {
  const VerifyDelivery(this._deliveryRepository, this._parcelRepository);

  final DeliveryRepository _deliveryRepository;
  final ParcelRepository _parcelRepository;

  Future<Result<Delivery>> call({
    required String deliveryId,
    required String inputPin,
    String? photoUrl,
  }) async {
    final cleanPin = inputPin.trim();
    if (cleanPin.length != 4 || int.tryParse(cleanPin) == null) {
      return const Err<Delivery>(
        ValidationFailure('Verification PIN must be a 4-digit numeric code'),
      );
    }

    final deliveryRes = await _deliveryRepository.getDeliveryById(deliveryId);
    return deliveryRes.fold(
      (delivery) async {
        if (delivery.status != DeliveryStatus.inTransit) {
          return const Err<Delivery>(
            ValidationFailure('Only deliveries in transit can be verified and completed'),
          );
        }

        if (delivery.verificationPin != cleanPin) {
          return const Err<Delivery>(
            ValidationFailure('Incorrect verification PIN. Please verify code with recipient.'),
          );
        }

        final updateRes = await _deliveryRepository.verifyDelivery(
          deliveryId: deliveryId,
          inputPin: cleanPin,
          photoUrl: photoUrl,
        );

        return updateRes.fold(
          (completedDelivery) async {
            // Transition underlying parcel to delivered
            await _parcelRepository.updateParcelStatus(
              id: completedDelivery.parcelId,
              status: ParcelStatus.delivered,
            );
            return Ok<Delivery>(completedDelivery);
          },
          (failure) => Err<Delivery>(failure),
        );
      },
      (failure) => Err<Delivery>(failure),
    );
  }
}
