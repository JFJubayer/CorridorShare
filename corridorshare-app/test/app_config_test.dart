import 'package:flutter_test/flutter_test.dart';

import 'package:corridorshare_app/core/config/app_config.dart';
import 'package:corridorshare_app/core/money/money.dart';
import 'package:corridorshare_app/features/wallet/wallet_controller.dart';

void main() {
  test('Supabase is the default data mode and requires credentials', () {
    final config = AppConfig.fromEnvironment();

    expect(config.dataMode, AppDataMode.supabase);
    expect(config.validateForStartup, throwsStateError);
  });

  test('live wallet state cannot be changed in the client', () {
    const config = AppConfig(dataMode: AppDataMode.supabase);
    final wallet = WalletController(config: config);

    expect(
      () => wallet.topUp(amount: Money.fromBdt(100), provider: 'bKash'),
      throwsStateError,
    );
  });
}
