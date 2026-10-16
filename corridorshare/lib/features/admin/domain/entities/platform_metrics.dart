import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_metrics.freezed.dart';

@freezed
abstract class PlatformMetrics with _$PlatformMetrics {
  const factory PlatformMetrics({
    required int totalUsers,
    required int totalTrips,
    required int totalParcels,
    required int activeDeliveries,
    required int completedDeliveries,
    required double totalVolumeBdt,
    required int openDisputesCount,
  }) = _PlatformMetrics;
}

enum DisputeResolution {
  refundSender,
  payoutTraveller,
  dismissed;
}
