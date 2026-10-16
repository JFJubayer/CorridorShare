import 'package:corridorshare/features/offers/data/models/offer_dto.dart';

abstract class OfferDataSource {
  Future<OfferDto> createOffer(OfferDto offer);

  Future<OfferDto> counterOffer({
    required String offerId,
    required double newPrice,
    required String counterByUserId,
  });

  Future<OfferDto> acceptOffer(String offerId);

  Future<OfferDto> rejectOffer(String offerId);

  Future<OfferDto> getOfferById(String offerId);

  Future<List<OfferDto>> getOffersForUser(String userId);
}
