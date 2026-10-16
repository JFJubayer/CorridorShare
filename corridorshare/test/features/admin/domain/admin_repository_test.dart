import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/admin/data/datasources/admin_datasource.dart';
import 'package:corridorshare/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:corridorshare/features/admin/domain/entities/platform_metrics.dart';
import 'package:corridorshare/features/delivery/data/datasources/in_memory_delivery_datasource.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/wallet/data/datasources/in_memory_wallet_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryTripDataSource tripDataSource;
  late InMemoryParcelDataSource parcelDataSource;
  late InMemoryDeliveryDataSource deliveryDataSource;
  late InMemoryWalletDataSource walletDataSource;
  late InMemoryAdminDataSource adminDataSource;
  late AdminRepositoryImpl adminRepository;

  setUp(() {
    tripDataSource = InMemoryTripDataSource(seed: true);
    parcelDataSource = InMemoryParcelDataSource(seed: true);
    deliveryDataSource = InMemoryDeliveryDataSource(seed: true);
    walletDataSource = InMemoryWalletDataSource();
    adminDataSource = InMemoryAdminDataSource(
      tripDataSource: tripDataSource,
      parcelDataSource: parcelDataSource,
      deliveryDataSource: deliveryDataSource,
      walletDataSource: walletDataSource,
    );
    adminRepository = AdminRepositoryImpl(adminDataSource);
  });

  group('AdminRepository', () {
    test('getPlatformMetrics aggregates platform numbers correctly', () async {
      final res = await adminRepository.getPlatformMetrics();
      expect(res, isA<Ok>());

      final metrics = res.getOrThrow();
      expect(metrics.totalUsers, greaterThan(0));
      expect(metrics.totalTrips, greaterThan(0));
      expect(metrics.totalParcels, greaterThan(0));
      expect(metrics.totalVolumeBdt, greaterThan(0));
    });

    test('resolveDispute with refundSender returns delivery and refunds sender', () async {
      final res = await adminRepository.resolveDispute(
        deliveryId: 'delivery-1',
        resolution: DisputeResolution.refundSender,
        adminNotes: 'Package not received, refunded.',
      );

      expect(res, isA<Ok>());
      final delivery = res.getOrThrow();
      expect(delivery.id, 'delivery-1');
    });

    test('resolveDispute with payoutTraveller releases escrow to traveller', () async {
      final res = await adminRepository.resolveDispute(
        deliveryId: 'delivery-1',
        resolution: DisputeResolution.payoutTraveller,
        adminNotes: 'Delivery verified by call, released payout.',
      );

      expect(res, isA<Ok>());
    });
  });
}
