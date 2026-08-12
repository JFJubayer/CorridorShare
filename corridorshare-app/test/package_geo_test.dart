import 'package:flutter_test/flutter_test.dart';
import 'package:corridorshare_app/core/geo/bangladesh_geo.dart';
import 'package:corridorshare_app/core/money/money.dart';
import 'package:corridorshare_app/models/package_model.dart';

void main() {
  test('dropoff must differ from pickup', () {
    expect(
      () => PackageModel(
        id: 'p',
        senderId: 's',
        itemDescription: 'x',
        reward: Money.fromBdt(10),
        status: PackageStatus.pending,
        pickup: const GeoPoint(23.8, 90.4),
        dropoff: const GeoPoint(23.8, 90.4),
        pickupRadiusMeters: 2000,
        distanceFromCorridor: 0,
        isNearMiss: false,
        routeInfo: 'r',
        eta: DateTime.utc(2026, 8, 1),
        itemType: 'Parcel',
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('Bangladesh route WKT is built from user places, not hardcoded N3', () {
    final dep = BangladeshGeo.byId('dhaka_uttara')!;
    final dest = BangladeshGeo.byId('sylhet')!;
    final wkt = BangladeshGeo.lineStringWkt(BangladeshGeo.routeBetween(dep, dest));
    expect(wkt.startsWith('LINESTRING('), isTrue);
    expect(wkt.contains('91.8687'), isTrue);
    expect(wkt.contains('90.4125 23.8103, 90.4203 24.7471'), isFalse);
  });
}
