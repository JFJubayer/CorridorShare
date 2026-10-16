import 'package:corridorshare/features/matching/domain/entities/match_check.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.now();

  Trip makeTrip({
    String from = 'Dhaka',
    String to = 'Chattogram',
    double capacity = 10.0,
    List<String> noCarry = const <String>['liquid', 'food'],
    DateTime? date,
  }) {
    return Trip(
      id: 'trip-1',
      travellerId: 'traveller-1',
      travellerName: 'Test Traveller',
      fromDistrict: from,
      fromArea: 'Uttara',
      toDistrict: to,
      toArea: 'Agrabad',
      departureDate: date ?? now.add(const Duration(days: 2)),
      capacityKg: capacity,
      noCarryTags: noCarry,
      createdAt: now,
    );
  }

  Parcel makeParcel({
    String from = 'Dhaka',
    String to = 'Chattogram',
    double weight = 2.0,
    List<String> tags = const <String>['documents'],
    DateTime? deadline,
  }) {
    return Parcel(
      id: 'parcel-1',
      senderId: 'sender-1',
      senderName: 'Test Sender',
      title: 'Package',
      fromDistrict: from,
      fromArea: 'Uttara',
      toDistrict: to,
      toArea: 'Agrabad',
      categoryTags: tags,
      weightKg: weight,
      deadline: deadline ?? now.add(const Duration(days: 3)),
      offeredPrice: 500.0,
      hasProhibitedItemsDeclaration: true,
      createdAt: now,
    );
  }

  group('MatchCheck compatibility logic', () {
    test('isRouteCompatible succeeds for matching districts', () {
      final trip = makeTrip(from: 'Dhaka', to: 'Chattogram');
      final parcel = makeParcel(from: 'dhaka', to: 'CHATTOGRAM');
      expect(MatchCheck.isRouteCompatible(trip: trip, parcel: parcel), isTrue);
    });

    test('isRouteCompatible fails for different routes', () {
      final trip = makeTrip(from: 'Dhaka', to: 'Chattogram');
      final parcel = makeParcel(from: 'Dhaka', to: 'Sylhet');
      expect(MatchCheck.isRouteCompatible(trip: trip, parcel: parcel), isFalse);
    });

    test('isDateCompatible succeeds when trip leaves before or on deadline', () {
      final trip = makeTrip(date: now.add(const Duration(days: 2)));
      final parcel = makeParcel(deadline: now.add(const Duration(days: 3)));
      expect(MatchCheck.isDateCompatible(trip: trip, parcel: parcel), isTrue);
    });

    test('isDateCompatible fails when trip leaves after parcel deadline', () {
      final trip = makeTrip(date: now.add(const Duration(days: 5)));
      final parcel = makeParcel(deadline: now.add(const Duration(days: 2)));
      expect(MatchCheck.isDateCompatible(trip: trip, parcel: parcel), isFalse);
    });

    test('isCapacityCompatible checks weight against traveller limit', () {
      final trip = makeTrip(capacity: 5.0);
      expect(
        MatchCheck.isCapacityCompatible(trip: trip, parcel: makeParcel(weight: 3.0)),
        isTrue,
      );
      expect(
        MatchCheck.isCapacityCompatible(trip: trip, parcel: makeParcel(weight: 7.0)),
        isFalse,
      );
    });

    test('isBlockedByNoCarry blocks parcels with restricted categories', () {
      final trip = makeTrip(noCarry: const <String>['liquid', 'perishable_food']);

      // Parcel with food
      final foodParcel = makeParcel(tags: const <String>['perishable_food']);
      expect(MatchCheck.isBlockedByNoCarry(trip: trip, parcel: foodParcel), isTrue);

      // Parcel with liquids
      final liquidParcel = makeParcel(tags: const <String>['liquids']);
      expect(MatchCheck.isBlockedByNoCarry(trip: trip, parcel: liquidParcel), isTrue);

      // Allowed parcel (books, documents)
      final docParcel = makeParcel(tags: const <String>['documents', 'books']);
      expect(MatchCheck.isBlockedByNoCarry(trip: trip, parcel: docParcel), isFalse);
    });
  });
}
