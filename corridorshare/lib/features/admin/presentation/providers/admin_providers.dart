import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/admin/domain/entities/platform_metrics.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:corridorshare/core/di/injection.dart'
    show adminDataSourceProvider, adminRepositoryProvider;

final platformMetricsProvider = FutureProvider<PlatformMetrics>((ref) async {
  final result = await ref.watch(adminRepositoryProvider).getPlatformMetrics();
  return result.fold(
    (metrics) => metrics,
    (failure) => throw failure,
  );
});

final disputedDeliveriesProvider = FutureProvider<List<Delivery>>((ref) async {
  final result =
      await ref.watch(adminRepositoryProvider).getDisputedDeliveries();
  return result.fold(
    (deliveries) => deliveries,
    (failure) => throw failure,
  );
});

class AdminActionController extends StateNotifier<AsyncValue<void>> {
  AdminActionController(this._ref) : super(const AsyncValue<void>.data(null));

  final Ref _ref;

  Future<bool> resolveDispute({
    required String deliveryId,
    required DisputeResolution resolution,
    required String adminNotes,
  }) async {
    state = const AsyncValue<void>.loading();
    final result = await _ref.read(adminRepositoryProvider).resolveDispute(
          deliveryId: deliveryId,
          resolution: resolution,
          adminNotes: adminNotes,
        );
    return result.fold(
      (_) {
        state = const AsyncValue<void>.data(null);
        _ref.invalidate(disputedDeliveriesProvider);
        _ref.invalidate(platformMetricsProvider);
        _ref.invalidate(deliveryByIdProvider(deliveryId));
        return true;
      },
      (failure) {
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return false;
      },
    );
  }
}

final adminActionControllerProvider =
    StateNotifierProvider<AdminActionController, AsyncValue<void>>((ref) {
  return AdminActionController(ref);
});
