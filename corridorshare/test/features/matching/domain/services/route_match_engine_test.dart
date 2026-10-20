import 'package:corridorshare/features/matching/domain/entities/route_match_result.dart';
import 'package:corridorshare/features/matching/domain/services/route_match_engine.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_size.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RouteMatchEngine', () {
    final baseTrip = Trip(
      id: 'trip-1',
      travellerId: 'traveller-1',
      travellerName: 'Tanvir Ahmed',
      fromDistrict: 'Dhaka',
      fromArea: 'Uttara',
      toDistrict: 'Mymensingh',
      toArea: 'Mymensingh Sadar',
      departureDate: DateTime(2026, 10, 24, 9, 0),
      capacityKg: 5.0,
      bookedKg: 2.2,
      noCarryTags: const <String>['liquids', 'fragile'],
      status: TripStatus.open,
      createdAt: DateTime(2026, 10, 18),
    );

    test('correctly evaluates direct route with zero detour', () {
      final directParcel = Parcel(
        id: 'p-direct',
        senderId: 's-1',
        senderName: 'Nila Akter',
        title: 'Documents',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara',
        toDistrict: 'Mymensingh',
        toArea: 'Mymensingh Sadar',
        weightKg: 1.2,
        size: ParcelSize.small,
        categoryTags: const <String>['documents'],
        deadline: DateTime(2026, 10, 24, 18, 0),
        offeredPrice: 350.0,
        status: ParcelStatus.open,
        createdAt: DateTime(2026, 10, 18),
      );

      final result = RouteMatchEngine.evaluate(
        trip: baseTrip,
        parcel: directParcel,
        isTopScore: true,
      );

      expect(result.isMatch, isTrue);
      expect(result.compatibilityType, RouteCompatibilityType.directRoute);
      expect(result.detourKm, 0);
      expect(result.isBestMatch, isTrue);
      expect(result.badges, contains('Best match'));
      expect(result.badges, contains('On your route'));
      expect(result.badges, contains('Fits 2.8 kg'));
    });

    test('identifies minor detour for Muktagacha (20 km)', () {
      final detourParcel = Parcel(
        id: 'p-detour',
        senderId: 's-2',
        senderName: 'Mitu Sultana',
        title: 'Clothes',
        fromDistrict: 'Dhaka',
        fromArea: 'Gulshan',
        toDistrict: 'Mymensingh',
        toArea: 'Muktagacha',
        weightKg: 1.5,
        size: ParcelSize.medium,
        categoryTags: const <String>['clothes'],
        deadline: DateTime(2026, 10, 25, 18, 0),
        offeredPrice: 300.0,
        status: ParcelStatus.open,
        createdAt: DateTime(2026, 10, 18),
      );

      final result = RouteMatchEngine.evaluate(
        trip: baseTrip,
        parcel: detourParcel,
      );

      expect(result.isMatch, isTrue);
      expect(result.compatibilityType, RouteCompatibilityType.minorDetour);
      expect(result.detourKm, 20);
      expect(result.badges, contains('Detour 20 km'));
      expect(result.badges, contains('Fits 2.8 kg'));
    });

    test('flags blocked parcels according to traveller noCarryTags', () {
      final liquidParcel = Parcel(
        id: 'p-liquid',
        senderId: 's-3',
        senderName: 'Hasan Ali',
        title: 'Mustard Oil & Ghee Jar',
        fromDistrict: 'Dhaka',
        fromArea: 'Mirpur',
        toDistrict: 'Mymensingh',
        toArea: 'Choto Bazar',
        weightKg: 2.0,
        size: ParcelSize.medium,
        categoryTags: const <String>['liquids', 'food'],
        deadline: DateTime(2026, 10, 24, 16, 0),
        offeredPrice: 420.0,
        status: ParcelStatus.open,
        createdAt: DateTime(2026, 10, 18),
      );

      final result = RouteMatchEngine.evaluate(
        trip: baseTrip,
        parcel: liquidParcel,
      );

      expect(result.isBlockedByRestrictions, isTrue);
      expect(result.isMatch, isFalse);
      expect(result.blockedReason, contains('liquids'));
    });

    test('recognizes intermediate sub-corridor stops on long routes', () {
      final sylhetTrip = Trip(
        id: 'trip-sylhet',
        travellerId: 'traveller-1',
        travellerName: 'Tanvir Ahmed',
        fromDistrict: 'Dhaka',
        fromArea: 'Mohakhali',
        toDistrict: 'Sylhet',
        toArea: 'Zindabazar',
        departureDate: DateTime(2026, 10, 25, 7, 30),
        capacityKg: 6.0,
        bookedKg: 0.0,
        noCarryTags: const <String>[],
        status: TripStatus.open,
        createdAt: DateTime(2026, 10, 18),
      );

      final subCorridorParcel = Parcel(
        id: 'p-corridor',
        senderId: 's-4',
        senderName: 'Kader Mia',
        title: 'Handloom Sarees',
        fromDistrict: 'Narsingdi',
        fromArea: 'Madhabdi',
        toDistrict: 'Brahmanbaria',
        toArea: 'Kastoghar',
        weightKg: 2.0,
        size: ParcelSize.medium,
        categoryTags: const <String>['fabrics'],
        deadline: DateTime(2026, 10, 26, 12, 0),
        offeredPrice: 400.0,
        status: ParcelStatus.open,
        createdAt: DateTime(2026, 10, 18),
      );

      final result = RouteMatchEngine.evaluate(
        trip: sylhetTrip,
        parcel: subCorridorParcel,
      );

      expect(result.isMatch, isTrue);
      expect(result.compatibilityType, RouteCompatibilityType.onCorridor);
      expect(result.detourKm, 0);
    });

    test('autoMatchParcelsForTrip filters, scores and sorts parcels', () {
      final parcels = <Parcel>[
        Parcel(
          id: 'p-1',
          senderId: 's-1',
          senderName: 'Nila Akter',
          title: 'Documents',
          fromDistrict: 'Dhaka',
          fromArea: 'Uttara',
          toDistrict: 'Mymensingh',
          toArea: 'Mymensingh Sadar',
          weightKg: 1.2,
          size: ParcelSize.small,
          categoryTags: const <String>['documents'],
          deadline: DateTime(2026, 10, 24, 18, 0),
          offeredPrice: 350.0,
          status: ParcelStatus.open,
          createdAt: DateTime(2026, 10, 18),
        ),
        Parcel(
          id: 'p-2',
          senderId: 's-2',
          senderName: 'Mitu Sultana',
          title: 'Clothes',
          fromDistrict: 'Dhaka',
          fromArea: 'Gulshan',
          toDistrict: 'Mymensingh',
          toArea: 'Muktagacha',
          weightKg: 1.5,
          size: ParcelSize.medium,
          categoryTags: const <String>['clothes'],
          deadline: DateTime(2026, 10, 25, 18, 0),
          offeredPrice: 300.0,
          status: ParcelStatus.open,
          createdAt: DateTime(2026, 10, 18),
        ),
        Parcel(
          id: 'p-incompatible',
          senderId: 's-3',
          senderName: 'Other',
          title: 'Fish',
          fromDistrict: 'Khulna',
          fromArea: 'Rupsha',
          toDistrict: 'Barishal',
          toArea: 'Nathullabad',
          weightKg: 1.0,
          size: ParcelSize.small,
          categoryTags: const <String>['food'],
          deadline: DateTime(2026, 10, 25, 18, 0),
          offeredPrice: 200.0,
          status: ParcelStatus.open,
          createdAt: DateTime(2026, 10, 18),
        ),
      ];

      final results = RouteMatchEngine.autoMatchParcelsForTrip(
        trip: baseTrip,
        allParcels: parcels,
      );

      // Incompatible corridor parcel should be filtered out
      expect(results.length, 2);
      expect(results.any((r) => r.parcel.id == 'p-incompatible'), isFalse);

      // Top match has 'Best match' badge
      final best = results.firstWhere((r) => r.isBestMatch);
      expect(best.parcel.id, 'p-1');
    });
  });
}
