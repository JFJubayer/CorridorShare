import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/usecases/accept_offer.dart';
import 'package:corridorshare/features/offers/domain/usecases/counter_offer.dart';
import 'package:corridorshare/features/offers/domain/usecases/create_offer.dart';
import 'package:corridorshare/features/offers/domain/usecases/get_my_offers.dart';
import 'package:corridorshare/features/offers/domain/usecases/reject_offer.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:corridorshare/core/di/injection.dart'
    show offerDataSourceProvider, offerRepositoryProvider;

final createOfferUseCaseProvider = Provider<CreateOffer>((ref) {
  return CreateOffer(ref.watch(offerRepositoryProvider));
});

final counterOfferUseCaseProvider = Provider<CounterOffer>((ref) {
  return CounterOffer(ref.watch(offerRepositoryProvider));
});

final acceptOfferUseCaseProvider = Provider<AcceptOffer>((ref) {
  return AcceptOffer(
    ref.watch(offerRepositoryProvider),
    ref.watch(parcelRepositoryProvider),
  );
});

final rejectOfferUseCaseProvider = Provider<RejectOffer>((ref) {
  return RejectOffer(ref.watch(offerRepositoryProvider));
});

final getMyOffersUseCaseProvider = Provider<GetMyOffers>((ref) {
  return GetMyOffers(ref.watch(offerRepositoryProvider));
});

final userOffersProvider = FutureProvider<List<Offer>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return const [];
  final useCase = ref.watch(getMyOffersUseCaseProvider);
  final result = await useCase(currentUser.id);
  return result.fold(
    (offers) => offers,
    (failure) => throw Exception(failure.message),
  );
});

final offerByIdProvider =
    FutureProvider.family<Offer, String>((ref, offerId) async {
  final repo = ref.watch(offerRepositoryProvider);
  final result = await repo.getOfferById(offerId);
  return result.fold(
    (offer) => offer,
    (failure) => throw Exception(failure.message),
  );
});

/// Offer Action Notifier for creating, countering, and accepting offers.
class OfferActionState {
  const OfferActionState({
    this.isLoading = false,
    this.errorMessage,
    this.successOffer,
  });

  final bool isLoading;
  final String? errorMessage;
  final Offer? successOffer;
}

class OfferActionController extends StateNotifier<OfferActionState> {
  OfferActionController(this._ref) : super(const OfferActionState());

  final Ref _ref;

  Future<bool> createOffer(Offer offer) async {
    state = const OfferActionState(isLoading: true);
    final useCase = _ref.read(createOfferUseCaseProvider);
    final result = await useCase(offer);
    return result.fold(
      (created) {
        state = OfferActionState(successOffer: created);
        _ref.invalidate(userOffersProvider);
        return true;
      },
      (failure) {
        state = OfferActionState(errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> counterOffer({
    required String offerId,
    required double newPrice,
    required String counterByUserId,
  }) async {
    state = const OfferActionState(isLoading: true);
    final useCase = _ref.read(counterOfferUseCaseProvider);
    final result = await useCase(
      offerId: offerId,
      newPrice: newPrice,
      counterByUserId: counterByUserId,
    );
    return result.fold(
      (updated) {
        state = OfferActionState(successOffer: updated);
        _ref.invalidate(userOffersProvider);
        _ref.invalidate(offerByIdProvider(offerId));
        return true;
      },
      (failure) {
        state = OfferActionState(errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> acceptOffer(String offerId) async {
    state = const OfferActionState(isLoading: true);
    final useCase = _ref.read(acceptOfferUseCaseProvider);
    final result = await useCase(offerId);
    return result.fold(
      (accepted) {
        state = OfferActionState(successOffer: accepted);
        _ref.invalidate(userOffersProvider);
        _ref.invalidate(offerByIdProvider(offerId));
        _ref.invalidate(parcelsFeedProvider);
        _ref.invalidate(myParcelsProvider);
        return true;
      },
      (failure) {
        state = OfferActionState(errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> rejectOffer(String offerId) async {
    state = const OfferActionState(isLoading: true);
    final useCase = _ref.read(rejectOfferUseCaseProvider);
    final result = await useCase(offerId);
    return result.fold(
      (rejected) {
        state = OfferActionState(successOffer: rejected);
        _ref.invalidate(userOffersProvider);
        _ref.invalidate(offerByIdProvider(offerId));
        return true;
      },
      (failure) {
        state = OfferActionState(errorMessage: failure.message);
        return false;
      },
    );
  }
}

final offerActionControllerProvider = StateNotifierProvider.autoDispose<
    OfferActionController, OfferActionState>((ref) {
  return OfferActionController(ref);
});
