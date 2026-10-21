import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/chats/presentation/providers/chat_providers.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
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
  final uid = currentUser?.id ?? 'traveller-1';
  final useCase = ref.watch(getMyOffersUseCaseProvider);
  final result = await useCase(uid);
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

final parcelOffersProvider =
    FutureProvider.family<List<Offer>, String>((ref, parcelId) async {
  final repo = ref.watch(offerRepositoryProvider);
  final result = await repo.getOffersForParcel(parcelId);
  return result.fold(
    (offers) => offers,
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
        _ref.invalidate(parcelOffersProvider);
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
      (updated) async {
        state = OfferActionState(successOffer: updated);
        _ref.invalidate(userOffersProvider);
        _ref.invalidate(offerByIdProvider(offerId));
        _ref.invalidate(parcelOffersProvider);

        final counterName = counterByUserId == updated.senderId
            ? updated.senderName
            : (counterByUserId == updated.travellerId
                ? updated.travellerName
                : (_ref.read(currentUserProvider)?.name.isNotEmpty == true
                    ? _ref.read(currentUserProvider)!.name
                    : updated.travellerName));
        final priceStr = updated.price.truncateToDouble() == updated.price
            ? updated.price.toInt().toString()
            : updated.price.toStringAsFixed(1);

        try {
          final sendMessage = _ref.read(sendMessageUseCaseProvider);
          await sendMessage(
            offerId: offerId,
            senderId: 'system',
            senderName: 'System',
            text: '$counterName countered with an offer of ৳$priceStr',
          );
        } catch (_) {
          // System message failure should not block counter-offer success
        }

        return true;
      },
      (failure) {
        state = OfferActionState(errorMessage: failure.message);
        return false;
      },
    );
  }

  Future<bool> acceptOffer(
    String offerId, {
    String? acceptedByUserId,
  }) async {
    if (mounted) state = const OfferActionState(isLoading: true);
    try {
      final useCase = _ref.read(acceptOfferUseCaseProvider);
      final result = await useCase(
        offerId,
        acceptedByUserId: acceptedByUserId,
      );
      return result.fold(
        (accepted) async {
          if (mounted) {
            state = OfferActionState(successOffer: accepted);
          }
          _ref.invalidate(userOffersProvider);
          _ref.invalidate(offerByIdProvider(offerId));
          _ref.invalidate(conversationsProvider);
          _ref.invalidate(parcelsFeedProvider);
          _ref.invalidate(myParcelsProvider);
          _ref.invalidate(parcelOffersProvider);

          final priceStr = accepted.price.truncateToDouble() == accepted.price
              ? accepted.price.toInt().toString()
              : accepted.price.toStringAsFixed(1);
          try {
            final sendMessage = _ref.read(sendMessageUseCaseProvider);
            if (accepted.status == OfferStatus.accepted) {
              await sendMessage(
                offerId: offerId,
                senderId: 'system',
                senderName: 'System',
                text: 'Deal agreed! Both sender and traveller have accepted the offer of ৳$priceStr.',
              );
            } else {
              final who = accepted.senderAccepted ? accepted.senderName : accepted.travellerName;
              final waitingFor = accepted.senderAccepted ? accepted.travellerName : accepted.senderName;
              await sendMessage(
                offerId: offerId,
                senderId: 'system',
                senderName: 'System',
                text: '$who accepted the offer of ৳$priceStr. Awaiting confirmation from $waitingFor.',
              );
            }
          } catch (_) {
            // System message non-blocking
          }

          return true;
        },
      (failure) {
        if (mounted) {
          state = OfferActionState(errorMessage: failure.message);
        }
        return false;
      },
    );
  } catch (e) {
    if (mounted) {
      state = OfferActionState(errorMessage: e.toString());
    }
    return false;
  }
}

Future<bool> rejectOffer(String offerId) async {
  if (mounted) state = const OfferActionState(isLoading: true);
  final useCase = _ref.read(rejectOfferUseCaseProvider);
  final result = await useCase(offerId);
  return result.fold(
    (rejected) {
      if (mounted) {
        state = OfferActionState(successOffer: rejected);
      }
      _ref.invalidate(userOffersProvider);
      _ref.invalidate(offerByIdProvider(offerId));
      _ref.invalidate(parcelOffersProvider);
      return true;
    },
    (failure) {
      if (mounted) {
        state = OfferActionState(errorMessage: failure.message);
      }
      return false;
    },
  );
}
}

final offerActionControllerProvider = StateNotifierProvider.autoDispose<
    OfferActionController, OfferActionState>((ref) {
  return OfferActionController(ref);
});
