import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:corridorshare/features/offers/domain/repositories/offer_repository.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/domain/repositories/parcel_repository.dart';

class AcceptOffer {
  const AcceptOffer(this._offerRepository, this._parcelRepository);

  final OfferRepository _offerRepository;
  final ParcelRepository _parcelRepository;

  Future<Result<Offer>> call(
    String offerId, {
    String? acceptedByUserId,
  }) async {
    final result = await _offerRepository.acceptOffer(
      offerId,
      acceptedByUserId: acceptedByUserId,
    );

    switch (result) {
      case Ok<Offer>(:final value):
        if (value.status == OfferStatus.accepted) {
          try {
            await _parcelRepository.updateParcelStatus(
              id: value.parcelId,
              status: ParcelStatus.matched,
            );
          } catch (_) {
            // Parcel status transition non-blocking for offer acceptance
          }
        }
        return Ok<Offer>(value);
      case Err<Offer>(:final failure):
        return Err<Offer>(failure);
    }
  }
}
