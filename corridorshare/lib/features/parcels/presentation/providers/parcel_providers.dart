import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/domain/usecases/create_parcel.dart';
import 'package:corridorshare/features/parcels/domain/usecases/get_my_parcels.dart';
import 'package:corridorshare/features/parcels/domain/usecases/get_parcels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:corridorshare/core/di/injection.dart'
    show parcelDataSourceProvider, parcelRepositoryProvider;

final createParcelUseCaseProvider = Provider<CreateParcel>((ref) {
  return CreateParcel(ref.watch(parcelRepositoryProvider));
});

final getParcelsUseCaseProvider = Provider<GetParcels>((ref) {
  return GetParcels(ref.watch(parcelRepositoryProvider));
});

final getMyParcelsUseCaseProvider = Provider<GetMyParcels>((ref) {
  return GetMyParcels(ref.watch(parcelRepositoryProvider));
});

/// Async notifier for the parcels feed.
class ParcelsFeedNotifier extends AsyncNotifier<List<Parcel>> {
  @override
  Future<List<Parcel>> build() async {
    return _fetchParcels();
  }

  Future<List<Parcel>> _fetchParcels({
    String? fromDistrict,
    String? toDistrict,
  }) async {
    final useCase = ref.read(getParcelsUseCaseProvider);
    final result = await useCase(
      fromDistrict: fromDistrict,
      toDistrict: toDistrict,
    );
    return result.fold(
      (parcels) => parcels,
      (failure) => throw Exception(failure.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchParcels());
  }

  Future<void> filter({String? fromDistrict, String? toDistrict}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchParcels(
        fromDistrict: fromDistrict,
        toDistrict: toDistrict,
      ),
    );
  }
}

final parcelsFeedProvider =
    AsyncNotifierProvider<ParcelsFeedNotifier, List<Parcel>>(
  ParcelsFeedNotifier.new,
);

/// Sender's own parcels.
final myParcelsProvider = FutureProvider<List<Parcel>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return const [];
  final useCase = ref.watch(getMyParcelsUseCaseProvider);
  final result = await useCase(currentUser.id);
  return result.fold(
    (parcels) => parcels,
    (failure) => throw Exception(failure.message),
  );
});

/// All available open parcels across the platform for match computation.
final allOpenParcelsProvider = FutureProvider<List<Parcel>>((ref) async {
  final useCase = ref.watch(getParcelsUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (parcels) => parcels.where((p) => p.status == ParcelStatus.open).toList(),
    (failure) => <Parcel>[],
  );
});

/// Post Parcel form state notifier.
class PostParcelState {
  const PostParcelState({
    this.isLoading = false,
    this.errorMessage,
    this.createdParcel,
  });

  final bool isLoading;
  final String? errorMessage;
  final Parcel? createdParcel;
}

class PostParcelController extends StateNotifier<PostParcelState> {
  PostParcelController(this._createParcel, this._ref)
      : super(const PostParcelState());

  final CreateParcel _createParcel;
  final Ref _ref;

  Future<bool> submitParcel(Parcel parcel) async {
    state = const PostParcelState(isLoading: true);
    final result = await _createParcel(parcel);
    return result.fold(
      (created) {
        state = PostParcelState(createdParcel: created);
        _ref.read(parcelsFeedProvider.notifier).refresh();
        _ref.invalidate(allOpenParcelsProvider);
        _ref.invalidate(myParcelsProvider);
        return true;
      },
      (failure) {
        state = PostParcelState(errorMessage: failure.message);
        return false;
      },
    );
  }
}

final postParcelControllerProvider = StateNotifierProvider.autoDispose<
    PostParcelController, PostParcelState>((ref) {
  return PostParcelController(ref.watch(createParcelUseCaseProvider), ref);
});
