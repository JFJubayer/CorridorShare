import 'package:flutter_test/flutter_test.dart';

import 'package:corridorshare_app/core/config/app_config.dart';
import 'package:corridorshare_app/core/geo/bangladesh_geo.dart';
import 'package:corridorshare_app/core/money/money.dart';
import 'package:corridorshare_app/features/listings/listings_controller.dart';
import 'package:corridorshare_app/models/package_model.dart';

void main() {
  const demoConfig = AppConfig(dataMode: AppDataMode.demo);

  test('creating a package requires recipient phone', () async {
    final listings = ListingsController(config: demoConfig);
    final pickup = const GeoPoint(23.8759, 90.3795);
    final dropoff = const GeoPoint(24.7471, 90.4203);

    await expectLater(
      listings.addPackage(
        currentUserId: 'sender-1',
        description: 'Docs',
        weight: 1.0,
        reward: Money.fromBdt(200),
        pickup: pickup,
        dropoff: dropoff,
        routeInfo: 'Dhaka → Mymensingh',
        liveRepository: null,
      ),
      throwsArgumentError,
    );

    await listings.addPackage(
      currentUserId: 'sender-1',
      description: 'Docs',
      weight: 1.0,
      reward: Money.fromBdt(200),
      pickup: pickup,
      dropoff: dropoff,
      routeInfo: 'Dhaka → Mymensingh',
      recipientPhone: '+8801712345678',
      liveRepository: null,
    );
    expect(listings.packages.last.recipientPhone, '+8801712345678');
  });

  test('nationwide places include non-N3 cities', () {
    expect(BangladeshGeo.byId('chittagong'), isNotNull);
    expect(BangladeshGeo.byId('rajshahi'), isNotNull);
  });
}
