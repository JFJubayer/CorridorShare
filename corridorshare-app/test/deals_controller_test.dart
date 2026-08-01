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
}
