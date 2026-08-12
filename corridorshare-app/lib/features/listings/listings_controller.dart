import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../core/money/money.dart';
import '../../models/package_model.dart';
import '../../models/trip_model.dart';
import '../../infrastructure/supabase/supabase_backend_repository.dart';
import 'data/listings_repository.dart';

class ListingsController extends ChangeNotifier {
  ListingsController({
    required AppConfig config,
    TripsRepository? tripsRepository,
    PackagesRepository? packagesRepository,
  })  : _config = config,
        _tripsRepository = tripsRepository ??
            FakeTripsRepository(seed: config.isDemo ? null : const []),
        _packagesRepository = packagesRepository ??
            FakePackagesRepository(seed: config.isDemo ? null : const []);

  final AppConfig _config;
  final TripsRepository _tripsRepository;
  final PackagesRepository _packagesRepository;
  List<TripModel> _liveTrips = const [];
  List<PackageModel> _livePackages = const [];
  List<PackageModel> _matchedPackages = const [];

  List<TripModel> get trips => _config.isDemo
      ? _tripsRepository.all
      : List.unmodifiable(_liveTrips);
  List<PackageModel> get packages => _config.isDemo
      ? _packagesRepository.all
      : List.unmodifiable(_livePackages);
  List<PackageModel> get matchedPackages => _config.isDemo
      ? _packagesRepository.all
      : List.unmodifiable(_matchedPackages);

  Future<void> hydrate(SupabaseBackendRepository repository) async {
    _liveTrips = await repository.fetchTrips();
    _livePackages = await repository.fetchPackages();
    notifyListeners();
  }

  Future<void> addTrip({
    required String currentUserId,
    required String departure,
    required String destination,
    required DateTime travelTime,
    required double capacity,
    required List<GeoPoint> routePoints,
    required SupabaseBackendRepository? liveRepository,
  }) async {
    if (departure.trim().isEmpty || destination.trim().isEmpty || !capacity.isFinite || capacity <= 0) {
      throw ArgumentError('Trip details must be complete and capacity must be positive.');
    }
    if (routePoints.length < 2) {
      throw ArgumentError('Trip route geometry must include at least two Bangladesh waypoints.');
    }
    if (routePoints.first.isSameAs(routePoints.last)) {
      throw ArgumentError('Departure and destination coordinates must differ.');
    }
    final trip = TripModel(
      id: _demoId('trip'),
      travelerId: currentUserId,
      departureCity: departure.trim(),
      destinationCity: destination.trim(),
      travelTime: travelTime,
      weightCapacityKg: capacity,
      status: TripStatus.scheduled,
      travelerName: 'You (Verified)',
      travelerRating: 5,
      routePoints: List.unmodifiable(routePoints),
    );
    if (_config.isDemo) {
      _tripsRepository.add(trip);
    } else {
      final repository = liveRepository;
      if (repository == null) throw StateError('Live Supabase repository is unavailable.');
      final created = await repository.createTrip(trip);
      _liveTrips = [created, ..._liveTrips];
    }
    notifyListeners();
  }

  Future<void> addPackage({
    required String currentUserId,
    required String description,
    required double weight,
    required Money reward,
    required GeoPoint pickup,
    required GeoPoint dropoff,
    required String routeInfo,
    required SupabaseBackendRepository? liveRepository,
    String? recipientPhone,
    String? recipientName,
  }) async {
    if (description.trim().isEmpty || !weight.isFinite || weight <= 0) {
      throw ArgumentError('Package details must be complete and weight must be positive.');
    }
    if (pickup.isSameAs(dropoff)) {
      throw ArgumentError('Pickup and dropoff must be different locations.');
    }
    final normalizedPhone = recipientPhone?.trim() ?? '';
    if (normalizedPhone.isEmpty) {
      throw ArgumentError('recipient_phone is required.');
    }
    final package = PackageModel(
      id: _demoId('package'),
      senderId: currentUserId,
      itemDescription: description.trim(),
      reward: reward,
      status: PackageStatus.pending,
      pickup: pickup,
      dropoff: dropoff,
      pickupRadiusMeters: 2000,
      distanceFromCorridor: 0,
      isNearMiss: false,
      routeInfo: routeInfo,
      eta: DateTime.now().toUtc().add(const Duration(days: 1)),
      itemType: '${description.trim()} (${weight.toStringAsFixed(1)}kg)',
      recipientPhone: normalizedPhone,
      recipientName: recipientName?.trim().isEmpty == true ? null : recipientName?.trim(),
      weightKg: weight,
    );
    if (_config.isDemo) {
      _packagesRepository.add(package);
    } else {
      final repository = liveRepository;
      if (repository == null) throw StateError('Live Supabase repository is unavailable.');
      final created = await repository.createPackage(package);
      _livePackages = [created, ..._livePackages];
    }
    notifyListeners();
  }

  Future<List<PackageModel>> matchForTrip({
    required String tripId,
    required SupabaseBackendRepository? liveRepository,
    double bufferDistanceMeters = 3000,
  }) async {
    if (_config.isDemo) {
      _matchedPackages = _packagesRepository.all;
      notifyListeners();
      return matchedPackages;
    }
    final repository = liveRepository;
    if (repository == null) throw StateError('Live Supabase repository is unavailable.');
    _matchedPackages = await repository.matchPackagesWithinCorridor(
      tripId: tripId,
      bufferDistanceMeters: bufferDistanceMeters,
    );
    notifyListeners();
    return matchedPackages;
  }
}

String _demoId(String kind) => '$kind-${DateTime.now().microsecondsSinceEpoch}';
