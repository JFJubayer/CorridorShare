import 'package:corridorshare/features/admin/domain/entities/platform_metrics.dart';
import 'package:corridorshare/features/delivery/data/datasources/delivery_datasource.dart';
import 'package:corridorshare/features/delivery/data/models/delivery_dto.dart';
import 'package:corridorshare/features/parcels/data/datasources/parcel_datasource.dart';
import 'package:corridorshare/features/trips/data/datasources/trip_datasource.dart';
import 'package:corridorshare/features/wallet/data/datasources/wallet_datasource.dart';

abstract class AdminDataSource {
  Future<PlatformMetrics> getPlatformMetrics();

  Future<List<DeliveryDto>> getDisputedDeliveries();

  Future<DeliveryDto> resolveDispute({
    required String deliveryId,
    required DisputeResolution resolution,
    required String adminNotes,
  });
}

class InMemoryAdminDataSource implements AdminDataSource {
  InMemoryAdminDataSource({
    required this.tripDataSource,
    required this.parcelDataSource,
    required this.deliveryDataSource,
    required this.walletDataSource,
  });

  final TripDataSource tripDataSource;
  final ParcelDataSource parcelDataSource;
  final DeliveryDataSource deliveryDataSource;
  final WalletDataSource walletDataSource;

  @override
  Future<PlatformMetrics> getPlatformMetrics() async {
    final trips = await tripDataSource.getTrips();
    final parcels = await parcelDataSource.getParcels();

    // Query platform deliveries
    final deliveries = await deliveryDataSource.getAllDeliveries();
    final active = deliveries.where((d) => d.status == 'inTransit' || d.status == 'matched').length;
    final completed = deliveries.where((d) => d.status == 'delivered').length;
    final disputed = deliveries.where((d) => d.status == 'disputed').length;

    final volume = deliveries.fold<double>(0.0, (acc, d) => acc + d.agreedPrice);

    return PlatformMetrics(
      totalUsers: 142,
      totalTrips: trips.length + 15,
      totalParcels: parcels.length + 28,
      activeDeliveries: active + 4,
      completedDeliveries: completed + 89,
      totalVolumeBdt: volume + 54200.0,
      openDisputesCount: disputed,
    );
  }

  @override
  Future<List<DeliveryDto>> getDisputedDeliveries() async {
    final allDeliveries = await deliveryDataSource.getAllDeliveries();
    return allDeliveries.where((d) => d.status == 'disputed' || d.isDisputed).toList();
  }

  @override
  Future<DeliveryDto> resolveDispute({
    required String deliveryId,
    required DisputeResolution resolution,
    required String adminNotes,
  }) async {
    final delivery = await deliveryDataSource.getDeliveryById(deliveryId);

    if (resolution == DisputeResolution.refundSender) {
      await walletDataSource.refundEscrow(
        userId: delivery.senderId,
        amount: delivery.agreedPrice,
        referenceId: deliveryId,
      );
    } else if (resolution == DisputeResolution.payoutTraveller) {
      await walletDataSource.releaseEscrow(
        senderId: delivery.senderId,
        travellerId: delivery.travellerId,
        amount: delivery.agreedPrice,
        referenceId: deliveryId,
      );
    }

    return deliveryDataSource.verifyDelivery(
      deliveryId: deliveryId,
      inputPin: delivery.verificationPin,
    );
  }
}
