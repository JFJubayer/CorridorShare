import 'package:flutter_test/flutter_test.dart';
import 'package:corridorshare_app/core/config/app_config.dart';
import 'package:corridorshare_app/providers/user_provider.dart';

void main() {
  group('UserProvider Unit Tests', () {
    late UserProvider userProvider;

    setUp(() {
      userProvider = UserProvider(
        config: const AppConfig(dataMode: AppDataMode.demo),
      );
    });

    test('Initial state values are correctly set', () {
      expect(userProvider.role, equals(AppRole.sender));
      expect(userProvider.isAuthenticated, isFalse);
      expect(userProvider.walletBalance, equals(14250.00));
      expect(userProvider.escrowLockedBalance, equals(1800.00));
      expect(userProvider.trips.length, equals(3));
      expect(userProvider.packages.length, equals(3));
    });

    test('Toggle role switches between sender and traveler', () {
      userProvider.toggleRole();
      expect(userProvider.role, equals(AppRole.traveler));
      expect(userProvider.isTraveler, isTrue);

      userProvider.toggleRole();
      expect(userProvider.role, equals(AppRole.sender));
      expect(userProvider.isTraveler, isFalse);
    });

    test('Explicit demo session updates phone and auth status', () {
      userProvider.startDemoSession('+8801712345678');
      expect(userProvider.isAuthenticated, isTrue);
      expect(userProvider.phone, equals('+8801712345678'));
      expect(userProvider.nidStatus, equals('verified'));
    });

    test('bKash and Nagad wallet top-ups increase balance', () async {
      final initialBalance = userProvider.availableWalletBalance;
      await userProvider.topUpBkash(500.0);
      expect(userProvider.availableWalletBalance, equals(initialBalance + 500.0));

      await userProvider.topUpNagad(1000.0);
      expect(userProvider.availableWalletBalance, equals(initialBalance + 1500.0));
      expect(userProvider.activityFeed.first, contains('Nagad'));
    });

    test('Rejects negative wallet operations', () async {
      await expectLater(userProvider.topUpBkash(-1), throwsArgumentError);
    });
  });
}
