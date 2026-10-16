import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:corridorshare/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';

class ReportDispute {
  const ReportDispute(this._deliveryRepository, this._parcelRepository);

  final DeliveryRepository _deliveryRepository;
  final ParcelRepository _parcelRepository;

  Future<Result<Delivery>> call({
    required String deliveryId,
    required String reason,
    required String reporterId,
  }) async {
    final cleanReason = reason.trim();
    if (cleanReason.isEmpty) {
      return const Err<Delivery>(
        ValidationFailure('Dispute reason cannot be empty'),
      );
    }

    final deliveryRes = await _deliveryRepository.getDeliveryById(deliveryId);
    return deliveryRes.fold(
      (delivery) async {
        if (delivery.status == DeliveryStatus.delivered ||
            delivery.status == DeliveryStatus.cancelled) {
          return const Err<Delivery>(
            ValidationFailure('Cannot dispute a completed or cancelled delivery'),
          );
        }

        final updateRes = await _deliveryRepository.reportDispute(
          deliveryId: deliveryId,
          reason: cleanReason,
          reporterId: reporterId,
        );

        return updateRes.fold(
          (disputedDelivery) async {
            // Transition underlying parcel to disputed
            await _parcelRepository.updateParcelStatus(
              id: disputedDelivery.parcelId,
              status: ParcelStatus.disputed,
            );
            return Ok<Delivery>(disputedDelivery);
          },
          (failure) => Err<Delivery>(failure),
        );
      },
      (failure) => Err<Delivery>(failure),
    );
  }
}
