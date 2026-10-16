import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/delivery/data/datasources/in_memory_delivery_datasource.dart';
import 'package:corridorshare/features/delivery/data/repositories/delivery_repository_impl.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:corridorshare/features/delivery/domain/usecases/confirm_pickup.dart';
import 'package:corridorshare/features/delivery/domain/usecases/get_delivery.dart';
import 'package:corridorshare/features/delivery/domain/usecases/report_dispute.dart';
import 'package:corridorshare/features/delivery/domain/usecases/verify_delivery.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/repositories/parcel_repository_impl.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryDeliveryDataSource deliveryDataSource;
  late DeliveryRepositoryImpl deliveryRepository;
  late InMemoryParcelDataSource parcelDataSource;
  late ParcelRepositoryImpl parcelRepository;

  late ConfirmPickup confirmPickup;
  late VerifyDelivery verifyDelivery;
  late ReportDispute reportDispute;
  late GetDelivery getDelivery;

  setUp(() {
    deliveryDataSource = InMemoryDeliveryDataSource(seed: true);
    deliveryRepository = DeliveryRepositoryImpl(deliveryDataSource);
    parcelDataSource = InMemoryParcelDataSource(seed: true);
    parcelRepository = ParcelRepositoryImpl(parcelDataSource);

    confirmPickup = ConfirmPickup(deliveryRepository, parcelRepository);
    verifyDelivery = VerifyDelivery(deliveryRepository, parcelRepository);
    reportDispute = ReportDispute(deliveryRepository, parcelRepository);
    getDelivery = GetDelivery(deliveryRepository);
  });

  group('ConfirmPickup', () {
    test('fails when photo proof is empty or whitespace only', () async {
      final res = await confirmPickup(
        deliveryId: 'delivery-1',
        photoUrl: '   ',
      );

      expect(res, isA<Err>());
    });

    test('updates delivery and underlying parcel to inTransit with photo and notes', () async {
      final res = await confirmPickup(
        deliveryId: 'delivery-1',
        photoUrl: 'https://example.com/proof.jpg',
        notes: 'Handed over at Farmgate, package intact.',
      );

      expect(res, isA<Ok>());
      final delivery = res.getOrThrow();
      expect(delivery.status, DeliveryStatus.inTransit);
      expect(delivery.pickupPhotoUrl, 'https://example.com/proof.jpg');
      expect(delivery.pickupNotes, 'Handed over at Farmgate, package intact.');
      expect(delivery.pickedUpAt, isNotNull);

      // Verify underlying parcel status transitioned to inTransit
      final parcelRes = await parcelRepository.getParcelById('parcel-1');
      expect(parcelRes.getOrThrow().status, ParcelStatus.inTransit);
    });
  });

  group('VerifyDelivery', () {
    test('fails when input PIN is not 4 digits', () async {
      final res = await verifyDelivery(
        deliveryId: 'delivery-2',
        inputPin: '12',
      );

      expect(res, isA<Err>());
    });

    test('fails when input PIN does not match delivery verification PIN', () async {
      // delivery-2 verificationPin is '4192'
      final res = await verifyDelivery(
        deliveryId: 'delivery-2',
        inputPin: '9999',
      );

      expect(res, isA<Err>());
    });

    test('succeeds when PIN matches and transitions parcel to delivered', () async {
      // delivery-2 verificationPin is '4192'
      final res = await verifyDelivery(
        deliveryId: 'delivery-2',
        inputPin: '4192',
      );

      expect(res, isA<Ok>());
      final delivery = res.getOrThrow();
      expect(delivery.status, DeliveryStatus.delivered);
      expect(delivery.deliveredAt, isNotNull);

      // Verify underlying parcel status transitioned to delivered
      final parcelRes = await parcelRepository.getParcelById('parcel-3');
      expect(parcelRes.getOrThrow().status, ParcelStatus.delivered);
    });
  });

  group('ReportDispute', () {
    test('fails when dispute reason is blank', () async {
      final res = await reportDispute(
        deliveryId: 'delivery-1',
        reason: '   ',
        reporterId: 'traveller-1',
      );

      expect(res, isA<Err>());
    });

    test('marks delivery as disputed and transitions parcel to disputed', () async {
      final res = await reportDispute(
        deliveryId: 'delivery-1',
        reason: 'Sender was unreachable at agreed meetup point.',
        reporterId: 'traveller-1',
      );

      expect(res, isA<Ok>());
      final delivery = res.getOrThrow();
      expect(delivery.status, DeliveryStatus.disputed);
      expect(delivery.isDisputed, isTrue);
      expect(delivery.disputeReason, 'Sender was unreachable at agreed meetup point.');

      // Verify underlying parcel status transitioned to disputed
      final parcelRes = await parcelRepository.getParcelById('parcel-1');
      expect(parcelRes.getOrThrow().status, ParcelStatus.disputed);
    });
  });

  group('GetDelivery', () {
    test('fetches delivery by ID and for user', () async {
      final byId = await getDelivery.byId('delivery-1');
      expect(byId, isA<Ok>());
      expect(byId.getOrThrow().id, 'delivery-1');

      final forUser = await getDelivery.forUser('traveller-1');
      expect(forUser, isA<Ok>());
      expect(forUser.getOrThrow().length, greaterThanOrEqualTo(2));
    });
  });
}
