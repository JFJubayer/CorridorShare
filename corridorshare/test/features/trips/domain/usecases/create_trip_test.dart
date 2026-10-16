import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/trips/data/datasources/in_memory_trip_datasource.dart';
import 'package:corridorshare/features/trips/data/models/trip_dto.dart';
import 'package:corridorshare/features/trips/data/repositories/trip_repository_impl.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:corridorshare/features/trips/domain/usecases/create_trip.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CreateTrip createTrip;
  late InMemoryTripDataSource dataSource;

  setUp(() {
    dataSource = InMemoryTripDataSource(initialTrips: <TripDto>[]);
    final repository = TripRepositoryImpl(dataSource);
    createTrip = CreateTrip(repository);
  });

  Trip makeTrip({
    String travellerId = 'user-1',
    String fromDistrict = 'Dhaka',
    String toDistrict = 'Chattogram',
    double capacityKg = 5.0,
    DateTime? departureDate,
  }) {
    return Trip(
      id: 'trip-test-1',
      travellerId: travellerId,
      travellerName: 'Test Traveller',
      fromDistrict: fromDistrict,
      fromArea: 'Uttara',
      toDistrict: toDistrict,
      toArea: 'Agrabad',
      departureDate: departureDate ?? DateTime.now().add(const Duration(days: 2)),
      capacityKg: capacityKg,
      noCarryTags: const <String>['liquids'],
      status: TripStatus.open,
      createdAt: DateTime.now(),
    );
  }

  test('succeeds for valid trip input', () async {
    final trip = makeTrip();
    final result = await createTrip(trip);

    expect(result, isA<Ok<Trip>>());
    expect(result.getOrThrow().fromDistrict, 'Dhaka');
    expect(result.getOrThrow().toDistrict, 'Chattogram');
  });

  test('rejects trip when travellerId is empty', () async {
    final trip = makeTrip(travellerId: '   ');
    final result = await createTrip(trip);

    expect(result, isA<Err<Trip>>());
    result.fold(
      (val) => fail('Should not succeed'),
      (err) => expect(err, isA<ValidationFailure>()),
    );
  });

  test('rejects trip when origin and destination districts are identical', () async {
    final trip = makeTrip(fromDistrict: 'Dhaka', toDistrict: 'Dhaka');
    final result = await createTrip(trip);

    expect(result, isA<Err<Trip>>());
  });

  test('rejects trip when capacity is zero or negative', () async {
    final trip = makeTrip(capacityKg: 0.0);
    final result = await createTrip(trip);

    expect(result, isA<Err<Trip>>());
  });

  test('rejects trip when capacity exceeds 50 kg limit', () async {
    final trip = makeTrip(capacityKg: 65.0);
    final result = await createTrip(trip);

    expect(result, isA<Err<Trip>>());
  });

  test('rejects trip when departure date is in the past', () async {
    final trip = makeTrip(
      departureDate: DateTime.now().subtract(const Duration(days: 2)),
    );
    final result = await createTrip(trip);

    expect(result, isA<Err<Trip>>());
  });
}
