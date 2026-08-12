import '../../../core/money/money.dart';
import '../../../models/package_model.dart';
import '../../../models/trip_model.dart';

abstract interface class TripsRepository {
  List<TripModel> get all;
  void add(TripModel trip);
}

abstract interface class PackagesRepository {
  List<PackageModel> get all;
  void add(PackageModel package);
}

class FakeTripsRepository implements TripsRepository {
  FakeTripsRepository({List<TripModel>? seed})
      : _trips = List<TripModel>.from(seed ?? _defaultTrips);

  final List<TripModel> _trips;

  @override
  List<TripModel> get all => List.unmodifiable(_trips);

  @override
  void add(TripModel trip) => _trips.insert(0, trip);
}

class FakePackagesRepository implements PackagesRepository {
  FakePackagesRepository({List<PackageModel>? seed})
      : _packages = List<PackageModel>.from(seed ?? _defaultPackages);

  final List<PackageModel> _packages;

  @override
  List<PackageModel> get all => List.unmodifiable(_packages);

  @override
  void add(PackageModel package) => _packages.insert(0, package);
}

final List<TripModel> _defaultTrips = List.unmodifiable([
  TripModel(
    id: '00000000-0000-4000-8000-000000000001',
    travelerId: '00000000-0000-4000-8000-000000000101',
    departureCity: 'Dhaka North (Uttara)',
    destinationCity: 'Mymensingh City Bypass',
    travelTime: DateTime.utc(2026, 8, 1, 14, 30),
    weightCapacityKg: 12,
    status: TripStatus.active,
    travelerName: 'Ahmed R.',
    travelerRating: 4.9,
    routePoints: const [GeoPoint(23.8759, 90.3795), GeoPoint(24.7471, 90.4203)],
  ),
  TripModel(
    id: '00000000-0000-4000-8000-000000000002',
    travelerId: '00000000-0000-4000-8000-000000000102',
    departureCity: 'Gazipur Chaurasta',
    destinationCity: 'Sylhet — Zindabazar',
    travelTime: DateTime.utc(2026, 8, 1, 17),
    weightCapacityKg: 8.5,
    status: TripStatus.scheduled,
    travelerName: 'Sara K.',
    travelerRating: 5,
    routePoints: const [GeoPoint(23.9999, 90.4203), GeoPoint(24.8949, 91.8687)],
  ),
  TripModel(
    id: '00000000-0000-4000-8000-000000000003',
    travelerId: '00000000-0000-4000-8000-000000000103',
    departureCity: 'Dhaka Airport Road',
    destinationCity: 'Chattogram — Agrabad',
    travelTime: DateTime.utc(2026, 8, 1, 20),
    weightCapacityKg: 15,
    status: TripStatus.scheduled,
    travelerName: 'Aminul Islam',
    travelerRating: 4.8,
    routePoints: const [GeoPoint(23.8513, 90.4086), GeoPoint(22.3239, 91.8117)],
  ),
]);

final List<PackageModel> _defaultPackages = List.unmodifiable([
  PackageModel(
    id: '00000000-0000-4000-8000-000000000201',
    senderId: '00000000-0000-4000-8000-000000000201',
    itemDescription: 'Urgent Legal Document Envelope',
    reward: Money.fromBdt(250),
    isPremium: true,
    status: PackageStatus.pending,
    pickup: const GeoPoint(23.822349, 90.414349),
    dropoff: const GeoPoint(24.7471, 90.4203),
    pickupRadiusMeters: 2000,
    distanceFromCorridor: 0,
    isNearMiss: false,
    routeInfo: 'Dhaka North → Gazipur Bypass',
    eta: DateTime.utc(2026, 8, 1, 16),
    itemType: 'Legal Document (0.5kg)',
    recipientPhone: '+8801711000001',
  ),
  PackageModel(
    id: '00000000-0000-4000-8000-000000000202',
    senderId: '00000000-0000-4000-8000-000000000202',
    itemDescription: 'Laptop Power Adapter & Parts',
    reward: Money.fromBdt(450),
    status: PackageStatus.pending,
    pickup: const GeoPoint(24.15, 90.4),
    dropoff: const GeoPoint(24.8949, 91.8687),
    pickupRadiusMeters: 2000,
    distanceFromCorridor: 0,
    isNearMiss: false,
    routeInfo: 'Gazipur → Sylhet',
    eta: DateTime.utc(2026, 8, 1, 18, 30),
    itemType: 'Electronics Cargo (2.5kg)',
    recipientPhone: '+8801711000002',
  ),
  PackageModel(
    id: '00000000-0000-4000-8000-000000000203',
    senderId: '00000000-0000-4000-8000-000000000203',
    itemDescription: 'Fresh Bakery Confectionery Box',
    reward: Money.fromBdt(350),
    status: PackageStatus.pending,
    pickup: const GeoPoint(24.5, 90.41),
    dropoff: const GeoPoint(22.3239, 91.8117),
    pickupRadiusMeters: 2000,
    distanceFromCorridor: 520,
    isNearMiss: true,
    routeInfo: 'Mymensingh → Chattogram Corridor',
    eta: DateTime.utc(2026, 8, 2, 9),
    itemType: 'Food Box (3.0kg)',
    recipientPhone: '+8801711000003',
  ),
]);
