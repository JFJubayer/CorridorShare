import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/usecases/create_trip.dart';
import 'package:corridorshare/features/trips/domain/usecases/get_my_trips.dart';
import 'package:corridorshare/features/trips/domain/usecases/get_trips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:corridorshare/core/di/injection.dart'
    show tripDataSourceProvider, tripRepositoryProvider;

final createTripUseCaseProvider = Provider<CreateTrip>((ref) {
  return CreateTrip(ref.watch(tripRepositoryProvider));
});

final getTripsUseCaseProvider = Provider<GetTrips>((ref) {
  return GetTrips(ref.watch(tripRepositoryProvider));
});

final getMyTripsUseCaseProvider = Provider<GetMyTrips>((ref) {
  return GetMyTrips(ref.watch(tripRepositoryProvider));
});

/// Async notifier for the trips feed.
class TripsFeedNotifier extends AsyncNotifier<List<Trip>> {
  @override
  Future<List<Trip>> build() async {
    return _fetchTrips();
  }

  Future<List<Trip>> _fetchTrips({
    String? fromDistrict,
    String? toDistrict,
  }) async {
    final useCase = ref.read(getTripsUseCaseProvider);
    final result = await useCase(
      fromDistrict: fromDistrict,
      toDistrict: toDistrict,
    );
    return result.fold(
      (trips) => trips,
      (failure) => throw Exception(failure.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchTrips());
  }

  Future<void> filter({String? fromDistrict, String? toDistrict}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _fetchTrips(
        fromDistrict: fromDistrict,
        toDistrict: toDistrict,
      ),
    );
  }
}

final tripsFeedProvider =
    AsyncNotifierProvider<TripsFeedNotifier, List<Trip>>(
  TripsFeedNotifier.new,
);

/// Traveller's own trips.
final myTripsProvider = FutureProvider<List<Trip>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return const [];
  final useCase = ref.watch(getMyTripsUseCaseProvider);
  final result = await useCase(currentUser.id);
  return result.fold(
    (trips) => trips,
    (failure) => throw Exception(failure.message),
  );
});

/// Post Trip form state notifier.
class PostTripState {
  const PostTripState({
    this.isLoading = false,
    this.errorMessage,
    this.createdTrip,
  });

  final bool isLoading;
  final String? errorMessage;
  final Trip? createdTrip;
}

class PostTripController extends StateNotifier<PostTripState> {
  PostTripController(this._createTrip, this._ref)
      : super(const PostTripState());

  final CreateTrip _createTrip;
  final Ref _ref;

  Future<bool> submitTrip(Trip trip) async {
    state = const PostTripState(isLoading: true);
    final result = await _createTrip(trip);
    return result.fold(
      (created) {
        state = PostTripState(createdTrip: created);
        _ref.read(tripsFeedProvider.notifier).refresh();
        _ref.invalidate(myTripsProvider);
        return true;
      },
      (failure) {
        state = PostTripState(errorMessage: failure.message);
        return false;
      },
    );
  }
}

final postTripControllerProvider =
    StateNotifierProvider.autoDispose<PostTripController, PostTripState>((ref) {
  return PostTripController(ref.watch(createTripUseCaseProvider), ref);
});
