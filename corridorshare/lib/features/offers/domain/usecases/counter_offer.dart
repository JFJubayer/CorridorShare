import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/repositories/offer_repository.dart';

class CounterOffer {
  const CounterOffer(this._repository);

  final OfferRepository _repository;

  Future<Result<Offer>> call({
    required String offerId,
    required double newPrice,
    required String counterByUserId,
  }) async {
    if (newPrice <= 0) {
      return const Err<Offer>(
        ValidationFailure('Counter offer price must be greater than 0 BDT'),
      );
    }
    return _repository.counterOffer(
      offerId: offerId,
      newPrice: newPrice,
      counterByUserId: counterByUserId,
    );
  }
}
