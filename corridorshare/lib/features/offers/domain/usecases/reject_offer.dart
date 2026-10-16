import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/repositories/offer_repository.dart';

class RejectOffer {
  const RejectOffer(this._repository);

  final OfferRepository _repository;

  Future<Result<Offer>> call(String offerId) {
    return _repository.rejectOffer(offerId);
  }
}
