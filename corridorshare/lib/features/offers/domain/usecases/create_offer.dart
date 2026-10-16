import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/repositories/offer_repository.dart';

class CreateOffer {
  const CreateOffer(this._repository);

  final OfferRepository _repository;

  Future<Result<Offer>> call(Offer offer) async {
    if (offer.price <= 0) {
      return const Err<Offer>(
        ValidationFailure('Offered price must be greater than 0 BDT'),
      );
    }
    if (offer.senderId == offer.travellerId) {
      return const Err<Offer>(
        ValidationFailure('Sender and traveller cannot be the same user'),
      );
    }
    return _repository.createOffer(offer);
  }
}
