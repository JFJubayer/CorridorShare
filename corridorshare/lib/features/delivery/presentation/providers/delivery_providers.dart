import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/domain/usecases/confirm_pickup.dart';
import 'package:corridorshare/features/delivery/domain/usecases/get_delivery.dart';
import 'package:corridorshare/features/delivery/domain/usecases/report_dispute.dart';
import 'package:corridorshare/features/delivery/domain/usecases/verify_delivery.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:corridorshare/core/di/injection.dart'
    show deliveryDataSourceProvider, deliveryRepositoryProvider;

final confirmPickupUseCaseProvider = Provider<ConfirmPickup>((ref) {
  return ConfirmPickup(
    ref.watch(deliveryRepositoryProvider),
    ref.watch(parcelRepositoryProvider),
  );
});

final verifyDeliveryUseCaseProvider = Provider<VerifyDelivery>((ref) {
  return VerifyDelivery(
    ref.watch(deliveryRepositoryProvider),
    ref.watch(parcelRepositoryProvider),
  );
});

final reportDisputeUseCaseProvider = Provider<ReportDispute>((ref) {
  return ReportDispute(
    ref.watch(deliveryRepositoryProvider),
    ref.watch(parcelRepositoryProvider),
  );
});

final getDeliveryUseCaseProvider = Provider<GetDelivery>((ref) {
  return GetDelivery(ref.watch(deliveryRepositoryProvider));
});

final deliveryByIdProvider =
    FutureProvider.family<Delivery, String>((ref, id) async {
  final result = await ref.watch(getDeliveryUseCaseProvider).byId(id);
  return result.fold(
    (delivery) => delivery,
    (failure) => throw failure,
  );
});

final deliveryForParcelProvider =
    FutureProvider.family<Delivery, String>((ref, parcelId) async {
  final result = await ref.watch(getDeliveryUseCaseProvider).byParcelId(parcelId);
  return result.fold(
    (delivery) => delivery,
    (failure) => throw failure,
  );
});

final userDeliveriesProvider =
    FutureProvider.family<List<Delivery>, String>((ref, userId) async {
  final result = await ref.watch(getDeliveryUseCaseProvider).forUser(userId);
  return result.fold(
    (deliveries) => deliveries,
    (failure) => throw failure,
  );
});

class DeliveryActionController extends StateNotifier<AsyncValue<void>> {
  DeliveryActionController(this._ref) : super(const AsyncValue<void>.data(null));

  final Ref _ref;

  Future<bool> confirmPickup({
    required String deliveryId,
    required String photoUrl,
    String? notes,
  }) async {
    state = const AsyncValue<void>.loading();
    final result = await _ref.read(confirmPickupUseCaseProvider)(
      deliveryId: deliveryId,
      photoUrl: photoUrl,
      notes: notes,
    );
    return result.fold(
      (delivery) {
        state = const AsyncValue<void>.data(null);
        _ref.invalidate(deliveryByIdProvider(deliveryId));
        _ref.invalidate(deliveryForParcelProvider(delivery.parcelId));
        _ref.invalidate(parcelsFeedProvider);
        _ref.invalidate(myParcelsProvider);
        return true;
      },
      (failure) {
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> verifyDelivery({
    required String deliveryId,
    required String inputPin,
    String? photoUrl,
  }) async {
    state = const AsyncValue<void>.loading();
    final result = await _ref.read(verifyDeliveryUseCaseProvider)(
      deliveryId: deliveryId,
      inputPin: inputPin,
      photoUrl: photoUrl,
    );
    return result.fold(
      (delivery) {
        state = const AsyncValue<void>.data(null);
        _ref.invalidate(deliveryByIdProvider(deliveryId));
        _ref.invalidate(deliveryForParcelProvider(delivery.parcelId));
        _ref.invalidate(parcelsFeedProvider);
        _ref.invalidate(myParcelsProvider);
        return true;
      },
      (failure) {
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> reportDispute({
    required String deliveryId,
    required String reason,
    required String reporterId,
  }) async {
    state = const AsyncValue<void>.loading();
    final result = await _ref.read(reportDisputeUseCaseProvider)(
      deliveryId: deliveryId,
      reason: reason,
      reporterId: reporterId,
    );
    return result.fold(
      (delivery) {
        state = const AsyncValue<void>.data(null);
        _ref.invalidate(deliveryByIdProvider(deliveryId));
        _ref.invalidate(deliveryForParcelProvider(delivery.parcelId));
        _ref.invalidate(parcelsFeedProvider);
        _ref.invalidate(myParcelsProvider);
        return true;
      },
      (failure) {
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return false;
      },
    );
  }
}

final deliveryActionControllerProvider =
    StateNotifierProvider<DeliveryActionController, AsyncValue<void>>((ref) {
  return DeliveryActionController(ref);
});
