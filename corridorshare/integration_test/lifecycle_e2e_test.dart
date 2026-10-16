import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/chats/data/datasources/in_memory_chat_datasource.dart';
import 'package:corridorshare/features/chats/data/repositories/chat_repository_impl.dart';
import 'package:corridorshare/features/chats/domain/usecases/send_message.dart';
import 'package:corridorshare/features/delivery/data/datasources/in_memory_delivery_datasource.dart';
import 'package:corridorshare/features/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:corridorshare/features/delivery/domain/usecases/confirm_pickup.dart';
import 'package:corridorshare/features/delivery/domain/usecases/verify_delivery.dart';
import 'package:corridorshare/features/matching/domain/entities/match_check.dart';
import 'package:corridorshare/features/matching/domain/usecases/find_parcels_for_trip.dart';
import 'package:corridorshare/features/offers/data/datasources/in_memory_offer_datasource.dart';
import 'package:corridorshare/features/offers/data/repositories/offer_repository_impl.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:corridorshare/features/offers/domain/usecases/accept_offer.dart';
import 'package:corridorshare/features/offers/domain/usecases/counter_offer.dart';
import 'package:corridorshare/features/offers/domain/usecases/create_offer.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/repositories/parcel_repository_impl.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/domain/usecases/create_parcel.dart';
import 'package:corridorshare/features/reviews/data/datasources/in_memory_review_datasource.dart';
import 'package:corridorshare/features/reviews/data/repositories/review_repository_impl.dart';
import 'package:corridorshare/features/reviews/domain/entities/review.dart';
import 'package:corridorshare/features/reviews/domain/usecases/review_usecases.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:corridorshare/features/trips/domain/usecases/create_trip.dart';
import 'package:corridorshare/features/wallet/data/datasources/in_memory_wallet_datasource.dart';
import 'package:corridorshare/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:corridorshare/features/wallet/domain/usecases/wallet_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CorridorShare Lifecycle E2E Integration Suite', () {
    late InMemoryTripDataSource tripDataSource;
    late InMemoryParcelDataSource parcelDataSource;
    late InMemoryOfferDataSource offerDataSource;
    late InMemoryDeliveryDataSource deliveryDataSource;
    late InMemoryWalletDataSource walletDataSource;
    late InMemoryChatDataSource chatDataSource;
    late InMemoryReviewDataSource reviewDataSource;

    setUp(() {
      tripDataSource = InMemoryTripDataSource();
      parcelDataSource = InMemoryParcelDataSource();
      offerDataSource = InMemoryOfferDataSource();
      deliveryDataSource = InMemoryDeliveryDataSource();
      walletDataSource = InMemoryWalletDataSource();
      chatDataSource = InMemoryChatDataSource(offerDataSource: offerDataSource);
      reviewDataSource = InMemoryReviewDataSource();
    });

    test(
        'Executes complete end-to-end lifecycle: Post Trip -> Post Parcel -> Route Match -> Offer Negotiation -> Pickup -> PIN Verification -> Escrow Release -> Review',
        () async {
      final tripRepo = TripRepositoryImpl(tripDataSource);
      final parcelRepo = ParcelRepositoryImpl(parcelDataSource);
      final offerRepo = OfferRepositoryImpl(offerDataSource);
      final deliveryRepo = DeliveryRepositoryImpl(deliveryDataSource);
      final walletRepo = WalletRepositoryImpl(walletDataSource);
      final chatRepo = ChatRepositoryImpl(chatDataSource);
      final reviewRepo = ReviewRepositoryImpl(reviewDataSource);

      const senderId = 'sender-fahim';
      const travellerId = 'traveller-abir';
      final departure = DateTime.now().add(const Duration(days: 2));
      final deadline = DateTime.now().add(const Duration(days: 3));

      // 1. Initial wallet top-up
      await walletDataSource.topUp(userId: senderId, amount: 2000.0);
      final initialWallet = (await walletRepo.getWallet(senderId)).getOrThrow();
      expect(initialWallet.balance, 2000.0);

      // 2. Post a Trip (Dhaka -> Chattogram)
      final createTrip = CreateTrip(tripRepo);
      final tripRes = await createTrip(Trip(
        id: 'trip-e2e',
        travellerId: travellerId,
        travellerName: 'Abir',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara',
        toDistrict: 'Chattogram',
        toArea: 'Agrabad',
        departureDate: departure,
        capacityKg: 10.0,
        noCarryTags: const ['liquids', 'fragile'],
        createdAt: DateTime.now(),
      ));
      expect(tripRes, isA<Ok>());
      final trip = tripRes.getOrThrow();
      expect(trip.status, TripStatus.open);

      // 3. Post a Parcel (Dhaka -> Chattogram, 3kg, non-prohibited)
      final createParcel = CreateParcel(parcelRepo);
      final parcelRes = await createParcel(Parcel(
        id: 'parcel-e2e',
        senderId: senderId,
        senderName: 'Fahim',
        title: 'Academic Books and Documents',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara',
        toDistrict: 'Chattogram',
        toArea: 'Agrabad',
        weightKg: 3.0,
        deadline: deadline,
        categoryTags: const ['books', 'documents'],
        offeredPrice: 850.0,
        hasProhibitedItemsDeclaration: true,
        createdAt: DateTime.now(),
      ));
      expect(parcelRes, isA<Ok>());
      final parcel = parcelRes.getOrThrow();
      expect(parcel.status, ParcelStatus.open);

      // 4. Corridor Matching Engine Evaluation
      expect(MatchCheck.isBlockedByNoCarry(trip: trip, parcel: parcel), false);
      expect(MatchCheck.isRouteCompatible(trip: trip, parcel: parcel), true);
      final findParcels = FindParcelsForTrip(parcelRepo);
      final matchedParcels = (await findParcels(trip)).getOrThrow();
      expect(matchedParcels.any((p) => p.id == parcel.id), true);

      // 5. Offer Negotiation Flow
      final createOffer = CreateOffer(offerRepo);
      final offerRes = await createOffer(Offer(
        id: 'offer-e2e',
        parcelId: parcel.id,
        tripId: trip.id,
        senderId: senderId,
        senderName: 'Fahim',
        travellerId: travellerId,
        travellerName: 'Abir',
        parcelTitle: parcel.title,
        fromDistrict: 'Dhaka',
        toDistrict: 'Chattogram',
        price: 850.0,
        status: OfferStatus.pendingTraveller,
        lastCounterBy: senderId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      expect(offerRes, isA<Ok>());
      final initialOffer = offerRes.getOrThrow();
      expect(initialOffer.status, OfferStatus.pendingTraveller);

      // 5b. Counter-offer by traveller
      final counterOffer = CounterOffer(offerRepo);
      final counterRes = await counterOffer(
        offerId: initialOffer.id,
        newPrice: 950.0,
        counterByUserId: travellerId,
      );
      expect(counterRes, isA<Ok>());
      final countered = counterRes.getOrThrow();
      expect(countered.status, OfferStatus.pendingSender);
      expect(countered.price, 950.0);

      // 5c. Real-time chat message during negotiation
      final sendMessage = SendMessage(chatRepo);
      final chatRes = await sendMessage(
        offerId: initialOffer.id,
        senderId: senderId,
        senderName: 'Fahim',
        text: 'Agreed on 950 BDT. Will meet at Kamalapur station.',
      );
      expect(chatRes, isA<Ok>());

      // 5d. Accept offer (transitions parcel to matched)
      final acceptOffer = AcceptOffer(offerRepo, parcelRepo);
      final acceptRes = await acceptOffer(initialOffer.id);
      expect(acceptRes, isA<Ok>());
      expect(acceptRes.getOrThrow().status, OfferStatus.accepted);

      // 5e. Hold Escrow in Wallet
      final holdEscrow = HoldEscrow(walletRepo);
      final holdRes = await holdEscrow(
        userId: senderId,
        amount: 950.0,
        referenceId: parcel.id,
        description: 'Escrow hold for parcel delivery',
      );
      expect(holdRes, isA<Ok>());
      final senderWalletAfterHold = (await walletRepo.getWallet(senderId)).getOrThrow();
      expect(senderWalletAfterHold.balance, 1050.0);
      expect(senderWalletAfterHold.escrowBalance, 950.0);

      // 6. Pickup Handover Verification with Photo Checklist
      final confirmPickup = ConfirmPickup(deliveryRepo, parcelRepo);
      final pickupRes = await confirmPickup(
        deliveryId: 'delivery-1',
        photoUrl: 'https://storage.internal/proof.jpg',
        notes: 'Handed over in good condition',
      );
      expect(pickupRes, isA<Ok>());
      expect(pickupRes.getOrThrow().status, DeliveryStatus.inTransit);

      // 7. Delivery Handover with 4-Digit Recipient PIN
      final verifyDelivery = VerifyDelivery(deliveryRepo, parcelRepo);
      final deliveryRes = await verifyDelivery(
        deliveryId: 'delivery-1',
        inputPin: '5829',
      );
      expect(deliveryRes, isA<Ok>());
      expect(deliveryRes.getOrThrow().status, DeliveryStatus.delivered);

      // 8. Escrow Settlement (Release funds from Sender Escrow to Traveller Balance)
      final releaseEscrow = ReleaseEscrow(walletRepo);
      final releaseRes = await releaseEscrow(
        senderId: senderId,
        travellerId: travellerId,
        amount: 950.0,
        referenceId: parcel.id,
      );
      expect(releaseRes, isA<Ok>());
      final senderFinalWallet = (await walletRepo.getWallet(senderId)).getOrThrow();
      final travellerFinalWallet = (await walletRepo.getWallet(travellerId)).getOrThrow();
      expect(senderFinalWallet.escrowBalance, 0.0);
      expect(travellerFinalWallet.balance, 950.0);

      // 9. Peer Review and Rating Submission
      final createReview = CreateReview(reviewRepo);
      final reviewRes = await createReview(Review(
        id: 'rev-e2e',
        deliveryId: 'delivery-1',
        reviewerId: senderId,
        reviewerName: 'Fahim',
        targetUserId: travellerId,
        targetUserName: 'Abir',
        rating: 5,
        comment: 'Excellent speed and safe delivery.',
        createdAt: DateTime.now(),
      ));
      expect(reviewRes, isA<Ok>());
      final avgRatingRes = await reviewRepo.getAverageRatingForUser(travellerId);
      expect(avgRatingRes.getOrThrow(), 5.0);
    });
  });
}
