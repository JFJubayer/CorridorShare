import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/offers/data/datasources/in_memory_offer_datasource.dart';
import 'package:corridorshare/features/offers/data/repositories/offer_repository_impl.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:corridorshare/features/offers/domain/usecases/accept_offer.dart';
import 'package:corridorshare/features/offers/domain/usecases/counter_offer.dart';
import 'package:corridorshare/features/offers/domain/usecases/create_offer.dart';
import 'package:corridorshare/features/offers/domain/usecases/get_my_offers.dart';
import 'package:corridorshare/features/offers/domain/usecases/reject_offer.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/repositories/parcel_repository_impl.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryOfferDataSource offerDataSource;
  late OfferRepositoryImpl offerRepository;
  late InMemoryParcelDataSource parcelDataSource;
  late ParcelRepositoryImpl parcelRepository;

  late CreateOffer createOffer;
  late CounterOffer counterOffer;
  late AcceptOffer acceptOffer;
  late RejectOffer rejectOffer;
  late GetMyOffers getMyOffers;

  setUp(() {
    offerDataSource = InMemoryOfferDataSource(seed: true);
    offerRepository = OfferRepositoryImpl(offerDataSource);
    parcelDataSource = InMemoryParcelDataSource(seed: true);
    parcelRepository = ParcelRepositoryImpl(parcelDataSource);

    createOffer = CreateOffer(offerRepository);
    counterOffer = CounterOffer(offerRepository);
    acceptOffer = AcceptOffer(offerRepository, parcelRepository);
    rejectOffer = RejectOffer(offerRepository);
    getMyOffers = GetMyOffers(offerRepository);
  });

  Offer buildSampleOffer({
    double price = 500,
    String senderId = 'user-a',
    String travellerId = 'user-b',
    OfferStatus status = OfferStatus.pendingTraveller,
  }) {
    final now = DateTime.now();
    return Offer(
      id: 'offer-new',
      parcelId: 'parcel-1',
      tripId: 'trip-1',
      senderId: senderId,
      senderName: 'User A',
      travellerId: travellerId,
      travellerName: 'User B',
      parcelTitle: 'Documents',
      fromDistrict: 'Dhaka',
      toDistrict: 'Chattogram',
      price: price,
      status: status,
      lastCounterBy: senderId,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('CreateOffer', () {
    test('fails if offer price is non-positive', () async {
      final offer = buildSampleOffer(price: 0);
      final res = await createOffer(offer);

      expect(res, isA<Err>());
    });

    test('fails if sender and traveller are identical', () async {
      final offer = buildSampleOffer(
        senderId: 'user-a',
        travellerId: 'user-a',
      );
      final res = await createOffer(offer);

      expect(res, isA<Err>());
    });

    test('creates offer with valid data', () async {
      final offer = buildSampleOffer(price: 550);
      final res = await createOffer(offer);

      expect(res, isA<Ok>());
      final created = res.getOrThrow();
      expect(created.price, 550);
      expect(created.status, OfferStatus.pendingTraveller);
    });
  });

  group('CounterOffer', () {
    test('fails if new price is non-positive', () async {
      final res = await counterOffer(
        offerId: 'offer-1',
        newPrice: -50,
        counterByUserId: 'traveller-1',
      );

      expect(res, isA<Err>());
    });

    test('updates price and toggles pending status to counterpart', () async {
      final res = await counterOffer(
        offerId: 'offer-1',
        newPrice: 600,
        counterByUserId: 'traveller-1', // Traveller countering
      );

      expect(res, isA<Ok>());
      final updated = res.getOrThrow();
      expect(updated.price, 600);
      expect(updated.status, OfferStatus.pendingSender);
      expect(updated.lastCounterBy, 'traveller-1');
    });
  });

  group('AcceptOffer', () {
    test('transitions offer to accepted and parcel to matched status when counterpart accepts', () async {
      // Initial state of parcel-1 is open
      final initialParcelRes = await parcelRepository.getParcelById('parcel-1');
      expect(initialParcelRes.getOrThrow().status, ParcelStatus.open);

      final acceptRes = await acceptOffer('offer-1', acceptedByUserId: 'traveller-1');
      expect(acceptRes, isA<Ok>());
      final acceptedOffer = acceptRes.getOrThrow();
      expect(acceptedOffer.status, OfferStatus.accepted);
      expect(acceptedOffer.senderAccepted, isTrue);
      expect(acceptedOffer.travellerAccepted, isTrue);

      // Verify parcel-1 transitioned to matched
      final updatedParcelRes = await parcelRepository.getParcelById('parcel-1');
      expect(updatedParcelRes.getOrThrow().status, ParcelStatus.matched);
    });

    test('requires two-way confirmation: item is NOT matched until BOTH sender and traveller accept', () async {
      // Create a fresh offer where neither or only creator has accepted
      final freshOffer = buildSampleOffer(
        price: 700,
        senderId: 'sender-1',
        travellerId: 'traveller-1',
        status: OfferStatus.pendingTraveller,
      );
      final createdRes = await createOffer(freshOffer);
      final created = createdRes.getOrThrow();
      expect(created.senderAccepted, isTrue);
      expect(created.travellerAccepted, isFalse);

      // Initially parcel is open
      final p1 = (await parcelRepository.getParcelById('parcel-1')).getOrThrow();
      expect(p1.status, ParcelStatus.open);

      // If only traveller has not accepted, parcel MUST NOT be matched yet
      // Counter-offer from traveller: now travellerAccepted = true, senderAccepted = false
      final counterRes = await counterOffer(
        offerId: created.id,
        newPrice: 750,
        counterByUserId: 'traveller-1',
      );
      final countered = counterRes.getOrThrow();
      expect(countered.travellerAccepted, isTrue);
      expect(countered.senderAccepted, isFalse);
      expect(countered.status, OfferStatus.pendingSender);

      // Parcel still NOT matched
      final p2 = (await parcelRepository.getParcelById('parcel-1')).getOrThrow();
      expect(p2.status, ParcelStatus.open);

      // Finally sender accepts -> both confirmed!
      final finalAccept = await acceptOffer(created.id, acceptedByUserId: 'sender-1');
      final completed = finalAccept.getOrThrow();
      expect(completed.status, OfferStatus.accepted);
      expect(completed.senderAccepted, isTrue);
      expect(completed.travellerAccepted, isTrue);

      // Now and only now is the parcel matched
      final p3 = (await parcelRepository.getParcelById('parcel-1')).getOrThrow();
      expect(p3.status, ParcelStatus.matched);
    });
  });

  group('RejectOffer', () {
    test('transitions offer to rejected', () async {
      final res = await rejectOffer('offer-2');
      expect(res, isA<Ok>());
      expect(res.getOrThrow().status, OfferStatus.rejected);
    });
  });

  group('GetMyOffers', () {
    test('retrieves user offers correctly', () async {
      final res = await getMyOffers('traveller-1');
      expect(res, isA<Ok>());
      final list = res.getOrThrow();
      expect(list.length, greaterThanOrEqualTo(2));
    });
  });
}
