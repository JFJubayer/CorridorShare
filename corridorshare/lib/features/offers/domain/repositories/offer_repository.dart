import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';

abstract class OfferRepository {
  Future<Result<Offer>> createOffer(Offer offer);

  Future<Result<Offer>> counterOffer({
    required String offerId,
    required double newPrice,
    required String counterByUserId,
  });

  Future<Result<Offer>> acceptOffer(String offerId);

  Future<Result<Offer>> rejectOffer(String offerId);

  Future<Result<Offer>> getOfferById(String offerId);

  Future<Result<List<Offer>>> getOffersForUser(String userId);
}
