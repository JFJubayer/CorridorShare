import 'dart:io';

import 'package:corridorshare/core/firebase/firestore_rest_service.dart';
import 'package:corridorshare/features/offers/data/datasources/firestore_offer_datasource.dart';
import 'package:corridorshare/features/offers/data/models/offer_dto.dart';
import 'package:flutter_test/flutter_test.dart';

class MockOfferRestService extends FirestoreRestService {
  MockOfferRestService();

  final Map<String, Map<String, dynamic>> database = {};

  @override
  Future<Map<String, dynamic>> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final key = '$collection/$docId';
    database[key] = Map<String, dynamic>.from(data);
    return {'id': docId, ...data};
  }

  @override
  Future<Map<String, dynamic>> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> fieldsToUpdate,
  ) async {
    final key = '$collection/$docId';
    final current = database[key] ?? {};
    database[key] = {...current, ...fieldsToUpdate};
    return database[key]!;
  }

  @override
  Future<List<Map<String, dynamic>>> getDocuments(String collection) async {
    final prefix = '$collection/';
    final results = <Map<String, dynamic>>[];
    for (final entry in database.entries) {
      if (entry.key.startsWith(prefix)) {
        final docId = entry.key.substring(prefix.length);
        results.add({'id': docId, ...entry.value});
      }
    }
    return results;
  }
}

void main() {
  late MockOfferRestService fakeRest;
  late String testStorageFileName;

  setUp(() {
    fakeRest = MockOfferRestService();
    testStorageFileName = 'test_offer_${DateTime.now().microsecondsSinceEpoch}.json';
  });

  tearDown(() {
    try {
      final home = Platform.environment['HOME'] ?? Directory.current.path;
      final file = File('$home/.corridorshare/$testStorageFileName');
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  });

  test('createOffer and acceptOffer persist across restarts', () async {
    final offerDs1 = FirestoreOfferDataSource(
      restService: fakeRest,
      seed: true,
      storageFileName: testStorageFileName,
    );

    final now = DateTime.now().toIso8601String();
    final newOffer = OfferDto(
      id: 'offer-custom-99',
      parcelId: 'parcel-custom',
      tripId: 'trip-custom',
      senderId: 'sender-1',
      senderName: 'Tania',
      travellerId: 'traveller-custom',
      travellerName: 'Karim',
      parcelTitle: 'Leather Bag',
      fromDistrict: 'Dhaka',
      toDistrict: 'Khulna',
      price: 600.0,
      status: 'pendingTraveller',
      lastCounterBy: 'sender-1',
      createdAt: now,
      updatedAt: now,
    );

    await offerDs1.createOffer(newOffer);
    await offerDs1.acceptOffer('offer-custom-99');

    // Verify remote database received the created and accepted offer
    expect(fakeRest.database.containsKey('offers/offer-custom-99'), isTrue);
    expect(fakeRest.database['offers/offer-custom-99']?['status'], equals('accepted'));

    // Session 2: Simulating app restart
    final offerDs2 = FirestoreOfferDataSource(
      restService: fakeRest,
      seed: true,
      storageFileName: testStorageFileName,
    );

    final retrieved = await offerDs2.getOfferById('offer-custom-99');
    expect(retrieved.status, equals('accepted'));
    expect(retrieved.parcelTitle, equals('Leather Bag'));
  });
}
