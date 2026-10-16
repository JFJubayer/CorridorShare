import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/parcels/data/datasources/in_memory_parcel_datasource.dart';
import 'package:corridorshare/features/parcels/data/models/parcel_dto.dart';
import 'package:corridorshare/features/parcels/data/repositories/parcel_repository_impl.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_size.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/domain/usecases/create_parcel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CreateParcel createParcel;
  late InMemoryParcelDataSource dataSource;

  setUp(() {
    dataSource = InMemoryParcelDataSource(initialParcels: <ParcelDto>[]);
    final repository = ParcelRepositoryImpl(dataSource);
    createParcel = CreateParcel(repository);
  });

  Parcel makeParcel({
    String senderId = 'sender-1',
    String title = 'Urgent Legal Documents',
    String fromDistrict = 'Dhaka',
    String toDistrict = 'Sylhet',
    double weightKg = 1.0,
    double offeredPrice = 600.0,
    bool hasProhibitedItemsDeclaration = true,
    DateTime? deadline,
  }) {
    return Parcel(
      id: 'parcel-test-1',
      senderId: senderId,
      senderName: 'Test Sender',
      title: title,
      fromDistrict: fromDistrict,
      fromArea: 'Dhanmondi',
      toDistrict: toDistrict,
      toArea: 'Zindabazar',
      categoryTags: const <String>['documents'],
      weightKg: weightKg,
      size: ParcelSize.small,
      deadline: deadline ?? DateTime.now().add(const Duration(days: 3)),
      offeredPrice: offeredPrice,
      status: ParcelStatus.open,
      hasProhibitedItemsDeclaration: hasProhibitedItemsDeclaration,
      createdAt: DateTime.now(),
    );
  }

  test('succeeds for valid parcel with prohibited items declaration', () async {
    final parcel = makeParcel();
    final result = await createParcel(parcel);

    expect(result, isA<Ok<Parcel>>());
    expect(result.getOrThrow().title, 'Urgent Legal Documents');
    expect(result.getOrThrow().hasProhibitedItemsDeclaration, isTrue);
  });

  test('strictly rejects parcel without prohibited items declaration', () async {
    final parcel = makeParcel(hasProhibitedItemsDeclaration: false);
    final result = await createParcel(parcel);

    expect(result, isA<Err<Parcel>>());
    result.fold(
      (val) => fail('Must not succeed without declaration'),
      (err) {
        expect(err, isA<ValidationFailure>());
        expect(err.message, contains('prohibited'));
      },
    );
  });

  test('rejects parcel with empty title', () async {
    final parcel = makeParcel(title: '  ');
    final result = await createParcel(parcel);

    expect(result, isA<Err<Parcel>>());
  });

  test('rejects parcel when origin and destination are the same', () async {
    final parcel = makeParcel(fromDistrict: 'Sylhet', toDistrict: 'Sylhet');
    final result = await createParcel(parcel);

    expect(result, isA<Err<Parcel>>());
  });

  test('rejects parcel with zero or negative weight', () async {
    final parcel = makeParcel(weightKg: 0.0);
    final result = await createParcel(parcel);

    expect(result, isA<Err<Parcel>>());
  });

  test('rejects parcel with zero or negative offered reward', () async {
    final parcel = makeParcel(offeredPrice: -50.0);
    final result = await createParcel(parcel);

    expect(result, isA<Err<Parcel>>());
  });

  test('rejects parcel with deadline in the past', () async {
    final parcel = makeParcel(
      deadline: DateTime.now().subtract(const Duration(days: 1)),
    );
    final result = await createParcel(parcel);

    expect(result, isA<Err<Parcel>>());
  });
}
