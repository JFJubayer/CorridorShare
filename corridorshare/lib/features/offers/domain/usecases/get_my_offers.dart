import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/repositories/offer_repository.dart';

class GetMyOffers {
  const GetMyOffers(this._repository);

  final OfferRepository _repository;

  Future<Result<List<Offer>>> call(String userId) {
    return _repository.getOffersForUser(userId);
  }
}
