import 'package:flutter_test/flutter_test.dart';

import 'package:corridorshare_app/core/config/app_config.dart';
import 'package:corridorshare_app/features/deals/deals_controller.dart';
import 'package:corridorshare_app/features/listings/listings_controller.dart';
import 'package:corridorshare_app/features/wallet/wallet_controller.dart';

void main() {
  const demoConfig = AppConfig(dataMode: AppDataMode.demo);

  test('messages are persisted by deal and collections are immutable', () async {
    final wallet = WalletController(config: demoConfig);
    final listings = ListingsController(config: demoConfig);
    final deals = DealsController(config: demoConfig, wallet: wallet);
    final deal = await deals.getOrCreateForPackage(
      package: listings.packages.first,
      travelerId: '00000000-0000-4000-8000-000000000111',
      tripId: listings.trips.first.id,
    );

    await deals.sendMessage(
      dealId: deal.id,
      senderId: '00000000-0000-4000-8000-000000000111',
      senderName: 'You',
      text: 'I can collect it at 4 PM.',
    );

    expect(deals.messagesFor(deal.id), hasLength(2));
    expect(
      () => deals.messagesFor(deal.id).add(deals.messagesFor(deal.id).first),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('escrow locks only once and payout cannot be released in the client', () async {
    final wallet = WalletController(config: demoConfig);
    final listings = ListingsController(config: demoConfig);
    final deals = DealsController(config: demoConfig, wallet: wallet);
    final deal = await deals.getOrCreateForPackage(
      package: listings.packages.first,
      travelerId: '00000000-0000-4000-8000-000000000111',
      tripId: listings.trips.first.id,
    );

    expect(await deals.lockEscrow(deal.id), isTrue);
    expect(await deals.lockEscrow(deal.id), isFalse);
    await expectLater(
      deals.requestPayoutRelease(dealId: deal.id, otp: '123456'),
      throwsA(isA<UnsupportedError>()),
    );
  });

  test('matches existing deals by packageId and tripId, not package alone', () async {
    final wallet = WalletController(config: demoConfig);
    final listings = ListingsController(config: demoConfig);
    final deals = DealsController(config: demoConfig, wallet: wallet);
    final package = listings.packages.first;
    final tripA = listings.trips.first;
    final tripB = listings.trips.length > 1 ? listings.trips[1] : listings.trips.first;

    final dealA = await deals.getOrCreateForPackage(
      package: package,
      travelerId: '00000000-0000-4000-8000-000000000111',
      tripId: tripA.id,
    );
    final dealB = await deals.getOrCreateForPackage(
      package: package,
      travelerId: '00000000-0000-4000-8000-000000000111',
      tripId: '${tripB.id}-alt',
      agreedReward: package.reward,
    );

    expect(dealA.id, isNot(dealB.id));
    expect(dealA.tripId, tripA.id);
    expect(dealB.tripId, '${tripB.id}-alt');

    final again = await deals.getOrCreateForPackage(
      package: package,
      travelerId: '00000000-0000-4000-8000-000000000111',
      tripId: tripA.id,
    );
    expect(again.id, dealA.id);
  });
}
