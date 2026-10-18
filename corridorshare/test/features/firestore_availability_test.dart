import 'package:corridorshare/core/firebase/firestore_rest_service.dart';
import 'package:corridorshare/features/parcels/data/datasources/firestore_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';
import 'package:corridorshare/features/trips/data/datasources/firestore_trip_datasource.dart';
import 'package:corridorshare/features/trips/data/models/trip_dto.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFirestoreRestService extends FirestoreRestService {
  FakeFirestoreRestService({
    this.mockTripDocs = const [],
    this.mockParcelDocs = const [],
  });

  final List<Map<String, dynamic>> mockTripDocs;
  final List<Map<String, dynamic>> mockParcelDocs;

  final Map<String, Map<String, dynamic>> savedDocs = {};

  @override
  Future<List<Map<String, dynamic>>> getDocuments(String collection) async {
    if (collection == 'trips') {
      return mockTripDocs;
    }
    if (collection == 'parcels') {
      return mockParcelDocs;
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    savedDocs['$collection/$docId'] = data;
    return {'id': docId, ...data};
  }
}

void main() {
  group('FirestoreRestCodec', () {
    test('encodes and decodes complex document map accurately', () {
      final original = <String, dynamic>{
        'title': 'Test Parcel',
        'weight': 2.5,
        'count': 3,
        'isFragile': true,
        'tags': ['electronics', 'urgent'],
        'meta': {'origin': 'Dhaka'},
      };

      final encoded = FirestoreRestCodec.encodeFields(original);
      expect(encoded['title'], {'stringValue': 'Test Parcel'});
      expect(encoded['weight'], {'doubleValue': 2.5});
      expect(encoded['count'], {'integerValue': '3'});
      expect(encoded['isFragile'], {'booleanValue': true});
      expect(encoded['tags']['arrayValue']['values'], [
        {'stringValue': 'electronics'},
        {'stringValue': 'urgent'},
      ]);

      final decoded = FirestoreRestCodec.decodeDocument({
        'name': 'projects/p/databases/(default)/documents/col/doc123',
        'fields': encoded,
      });

      expect(decoded['id'], 'doc123');
      expect(decoded['title'], 'Test Parcel');
      expect(decoded['weight'], 2.5);
      expect(decoded['count'], 3);
      expect(decoded['isFragile'], true);
      expect(decoded['tags'], ['electronics', 'urgent']);
      expect(decoded['meta']['origin'], 'Dhaka');
    });
  });

  group('FirestoreTripDataSource - available data only', () {
    test('filters and returns only available (open, future date, capacity > 0) trips', () async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1)).toIso8601String();
      final yesterday = now.subtract(const Duration(days: 1)).toIso8601String();

      final fakeRest = FakeFirestoreRestService(
        mockTripDocs: [
          // 1. Available trip (open, future date, capacity > 0) -> SHOULD BE RETURNED
          {
            'id': 'trip-available-1',
            'travellerId': 'traveller-1',
            'travellerName': 'Rafiq',
            'fromDistrict': 'Dhaka',
            'fromArea': 'Uttara',
            'toDistrict': 'Chattogram',
            'toArea': 'Agrabad',
            'departureDate': tomorrow,
            'capacityKg': 5.0,
            'status': 'open',
            'createdAt': now.toIso8601String(),
          },
          // 2. Completed trip -> SHOULD BE EXCLUDED
          {
            'id': 'trip-completed',
            'travellerId': 'traveller-2',
            'travellerName': 'Karim',
            'fromDistrict': 'Dhaka',
            'fromArea': 'Mirpur',
            'toDistrict': 'Sylhet',
            'toArea': 'Ambarkhana',
            'departureDate': tomorrow,
            'capacityKg': 5.0,
            'status': 'completed',
            'createdAt': now.toIso8601String(),
          },
          // 3. Cancelled trip -> SHOULD BE EXCLUDED
          {
            'id': 'trip-cancelled',
            'travellerId': 'traveller-3',
            'travellerName': 'Jamal',
            'fromDistrict': 'Dhaka',
            'fromArea': 'Dhanmondi',
            'toDistrict': 'Rajshahi',
            'toArea': 'Shaheb Bazar',
            'departureDate': tomorrow,
            'capacityKg': 5.0,
            'status': 'cancelled',
            'createdAt': now.toIso8601String(),
          },
          // 4. Past departure trip -> SHOULD BE EXCLUDED
          {
            'id': 'trip-past',
            'travellerId': 'traveller-4',
            'travellerName': 'Kamal',
            'fromDistrict': 'Dhaka',
            'fromArea': 'Gulshan',
            'toDistrict': 'Chattogram',
            'toArea': 'GEC',
            'departureDate': yesterday,
            'capacityKg': 5.0,
            'status': 'open',
            'createdAt': now.toIso8601String(),
          },
          // 5. Zero capacity trip -> SHOULD BE EXCLUDED
          {
            'id': 'trip-zero-cap',
            'travellerId': 'traveller-5',
            'travellerName': 'Tareq',
            'fromDistrict': 'Dhaka',
            'fromArea': 'Banani',
            'toDistrict': 'Khulna',
            'toArea': 'Shibbari',
            'departureDate': tomorrow,
            'capacityKg': 0.0,
            'status': 'open',
            'createdAt': now.toIso8601String(),
          },
        ],
      );

      final dataSource = FirestoreTripDataSource(restService: fakeRest);
      final trips = await dataSource.getTrips();

      expect(trips.length, 1);
      expect(trips.first.id, 'trip-available-1');
      expect(trips.first.status, 'open');
    });

    test('stores trip to Firestore collection with docId', () async {
      final fakeRest = FakeFirestoreRestService();
      final dataSource = FirestoreTripDataSource(restService: fakeRest);

      final trip = TripDto(
        id: 'new-trip-123',
        travellerId: 'traveller-abc',
        travellerName: 'Travel Guy',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara',
        toDistrict: 'Sylhet',
        toArea: 'Zindabazar',
        departureDate: DateTime.now().add(const Duration(days: 2)).toIso8601String(),
        capacityKg: 10.0,
        status: 'open',
        createdAt: DateTime.now().toIso8601String(),
      );

      final created = await dataSource.createTrip(trip);
      expect(created.id, 'new-trip-123');
      expect(fakeRest.savedDocs.containsKey('trips/new-trip-123'), isTrue);
      expect(fakeRest.savedDocs['trips/new-trip-123']!['fromDistrict'], 'Dhaka');
    });
  });

  group('FirestoreParcelDataSource - available data only', () {
    test('filters and returns only available (open, future deadline) parcels', () async {
      final now = DateTime.now();
      final inThreeDays = now.add(const Duration(days: 3)).toIso8601String();
      final yesterday = now.subtract(const Duration(days: 1)).toIso8601String();

      final fakeRest = FakeFirestoreRestService(
        mockParcelDocs: [
          // 1. Available parcel (open, future deadline) -> SHOULD BE RETURNED
          {
            'id': 'parcel-available-1',
            'senderId': 'sender-1',
            'senderName': 'Tanvir',
            'title': 'Legal Docs',
            'fromDistrict': 'Dhaka',
            'fromArea': 'Gulshan',
            'toDistrict': 'Chattogram',
            'toArea': 'Agrabad',
            'weightKg': 1.0,
            'size': 'small',
            'deadline': inThreeDays,
            'offeredPrice': 500.0,
            'status': 'open',
            'createdAt': now.toIso8601String(),
          },
          // 2. Matched parcel -> SHOULD BE EXCLUDED
          {
            'id': 'parcel-matched',
            'senderId': 'sender-2',
            'senderName': 'Nadia',
            'title': 'Electronics',
            'fromDistrict': 'Dhaka',
            'fromArea': 'Mohakhali',
            'toDistrict': 'Chattogram',
            'toArea': 'GEC',
            'weightKg': 2.0,
            'size': 'medium',
            'deadline': inThreeDays,
            'offeredPrice': 800.0,
            'status': 'matched',
            'createdAt': now.toIso8601String(),
          },
          // 3. Delivered parcel -> SHOULD BE EXCLUDED
          {
            'id': 'parcel-delivered',
            'senderId': 'sender-3',
            'senderName': 'Akbar',
            'title': 'Clothing',
            'fromDistrict': 'Dhaka',
            'fromArea': 'Mirpur',
            'toDistrict': 'Rajshahi',
            'toArea': 'Shaheb Bazar',
            'weightKg': 1.5,
            'size': 'medium',
            'deadline': inThreeDays,
            'offeredPrice': 400.0,
            'status': 'delivered',
            'createdAt': now.toIso8601String(),
          },
          // 4. Past deadline parcel -> SHOULD BE EXCLUDED
          {
            'id': 'parcel-past-deadline',
            'senderId': 'sender-4',
            'senderName': 'Hasan',
            'title': 'Expired Medicine',
            'fromDistrict': 'Dhaka',
            'fromArea': 'Farmgate',
            'toDistrict': 'Sylhet',
            'toArea': 'Zindabazar',
            'weightKg': 0.5,
            'size': 'small',
            'deadline': yesterday,
            'offeredPrice': 300.0,
            'status': 'open',
            'createdAt': now.toIso8601String(),
          },
        ],
      );

      final dataSource = FirestoreParcelDataSource(restService: fakeRest);
      final parcels = await dataSource.getParcels();

      expect(parcels.length, 1);
      expect(parcels.first.id, 'parcel-available-1');
      expect(parcels.first.status, 'open');
    });

    test('stores parcel to Firestore collection with docId', () async {
      final fakeRest = FakeFirestoreRestService();
      final dataSource = FirestoreParcelDataSource(restService: fakeRest);

      final parcel = ParcelDto(
        id: 'new-parcel-456',
        senderId: 'sender-xyz',
        senderName: 'Sender Guy',
        title: 'MacBook Charger',
        fromDistrict: 'Dhaka',
        fromArea: 'Dhanmondi',
        toDistrict: 'Chattogram',
        toArea: 'Panchlaish',
        weightKg: 0.5,
        deadline: DateTime.now().add(const Duration(days: 4)).toIso8601String(),
        offeredPrice: 600.0,
        status: 'open',
        createdAt: DateTime.now().toIso8601String(),
      );

      final created = await dataSource.createParcel(parcel);
      expect(created.id, 'new-parcel-456');
      expect(fakeRest.savedDocs.containsKey('parcels/new-parcel-456'), isTrue);
      expect(fakeRest.savedDocs['parcels/new-parcel-456']!['title'], 'MacBook Charger');
    });
  });
}
