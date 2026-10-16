import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/matching/domain/usecases/find_parcels_for_trip.dart';
import 'package:corridorshare/features/matching/domain/usecases/find_trips_for_parcel.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';
import 'package:corridorshare/features/parcels/data/repositories/parcel_repository_impl.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/trips/data/models/trip_dto.dart';
import 'package:corridorshare/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();

  late FindParcelsForTrip findParcels;
  late FindTripsForParcel findTrips;
  late InMemoryParcelDataSource parcelDataSource;
  late InMemoryTripDataSource tripDataSource;

  setUp(() {
    parcelDataSource = InMemoryParcelDataSource(
      initialParcels: <ParcelDto>[
        ParcelDto(
          id: 'p-doc',
          senderId: 's-1',
          senderName: 'Sender 1',
          title: 'Legal Papers',
          fromDistrict: 'Dhaka',
          fromArea: 'Uttara',
          toDistrict: 'Chattogram',
          toArea: 'Agrabad',
          categoryTags: const <String>['documents'],
          weightKg: 1.0,
          deadline: now.add(const Duration(days: 4)).toIso8601String(),
          offeredPrice: 500.0,
          status: 'open',
          hasProhibitedItemsDeclaration: true,
          createdAt: now.toIso8601String(),
        ),
        ParcelDto(
          id: 'p-liquid',
          senderId: 's-2',
          senderName: 'Sender 2',
          title: 'Specialty Syrup Bottles',
          fromDistrict: 'Dhaka',
          fromArea: 'Mirpur',
          toDistrict: 'Chattogram',
          toArea: 'GEC',
          categoryTags: const <String>['liquid', 'fragile'],
          weightKg: 2.0,
          deadline: now.add(const Duration(days: 4)).toIso8601String(),
          offeredPrice: 600.0,
          status: 'open',
          hasProhibitedItemsDeclaration: true,
          createdAt: now.toIso8601String(),
        ),
        ParcelDto(
          id: 'p-heavy',
          senderId: 's-3',
          senderName: 'Sender 3',
          title: 'Heavy Machinery Part',
          fromDistrict: 'Dhaka',
          fromArea: 'Mohakhali',
          toDistrict: 'Chattogram',
          toArea: 'Panchlaish',
          categoryTags: const <String>['tools'],
          weightKg: 15.0,
          deadline: now.add(const Duration(days: 4)).toIso8601String(),
          offeredPrice: 1500.0,
          status: 'open',
          hasProhibitedItemsDeclaration: true,
          createdAt: now.toIso8601String(),
        ),
      ],
    );

    tripDataSource = InMemoryTripDataSource(
      initialTrips: <TripDto>[
        TripDto(
          id: 't-1',
          travellerId: 'traveller-1',
          travellerName: 'Traveller 1',
          fromDistrict: 'Dhaka',
          fromArea: 'Airport',
          toDistrict: 'Chattogram',
          toArea: 'Station',
          departureDate: now.add(const Duration(days: 2)).toIso8601String(),
          capacityKg: 5.0,
          noCarryTags: const <String>['liquid'],
          status: 'open',
          createdAt: now.toIso8601String(),
        ),
      ],
    );

    findParcels = FindParcelsForTrip(ParcelRepositoryImpl(parcelDataSource));
    findTrips = FindTripsForParcel(TripRepositoryImpl(tripDataSource));
  });

  test('FindParcelsForTrip returns compatible parcel and excludes liquid & heavy',
      () async {
    final trip = Trip(
      id: 't-1',
      travellerId: 'traveller-1',
      travellerName: 'Traveller 1',
      fromDistrict: 'Dhaka',
      fromArea: 'Airport',
      toDistrict: 'Chattogram',
      toArea: 'Station',
      departureDate: now.add(const Duration(days: 2)),
      capacityKg: 5.0,
      noCarryTags: const <String>['liquid'],
      status: TripStatus.open,
      createdAt: now,
    );

    final result = await findParcels(trip);
    expect(result, isA<Ok<List<Parcel>>>());
    final parcels = result.getOrThrow();

    // Only 'p-doc' fits:
    // 'p-liquid' blocked by no-carry: 'liquid'
    // 'p-heavy' blocked by capacity limit (15 kg > 5 kg)
    expect(parcels.length, 1);
    expect(parcels.first.id, 'p-doc');
  });

  test('FindTripsForParcel matches traveller for legal papers', () async {
    final parcel = Parcel(
      id: 'p-doc',
      senderId: 's-1',
      senderName: 'Sender 1',
      title: 'Legal Papers',
      fromDistrict: 'Dhaka',
      fromArea: 'Uttara',
      toDistrict: 'Chattogram',
      toArea: 'Agrabad',
      categoryTags: const <String>['documents'],
      weightKg: 1.0,
      deadline: now.add(const Duration(days: 4)),
      offeredPrice: 500.0,
      status: ParcelStatus.open,
      hasProhibitedItemsDeclaration: true,
      createdAt: now,
    );

    final result = await findTrips(parcel);
    expect(result, isA<Ok<List<Trip>>>());
    final trips = result.getOrThrow();
    expect(trips.length, 1);
    expect(trips.first.id, 't-1');
  });

  test('FindTripsForParcel excludes traveller when parcel contains no-carry item',
      () async {
    final liquidParcel = Parcel(
      id: 'p-liquid',
      senderId: 's-2',
      senderName: 'Sender 2',
      title: 'Liquid Medicine',
      fromDistrict: 'Dhaka',
      fromArea: 'Uttara',
      toDistrict: 'Chattogram',
      toArea: 'Agrabad',
      categoryTags: const <String>['liquid'],
      weightKg: 1.0,
      deadline: now.add(const Duration(days: 4)),
      offeredPrice: 500.0,
      status: ParcelStatus.open,
      hasProhibitedItemsDeclaration: true,
      createdAt: now,
    );

    final result = await findTrips(liquidParcel);
    expect(result, isA<Ok<List<Trip>>>());
    expect(result.getOrThrow(), isEmpty);
  });
}
