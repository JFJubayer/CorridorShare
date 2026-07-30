import 'package:flutter_test/flutter_test.dart';
import 'package:corridorshare_app/providers/user_provider.dart';

void main() {
  group('UserProvider Unit Tests', () {
    late UserProvider userProvider;

    setUp(() {
      userProvider = UserProvider();
    });

    test('Initial state values are correctly set', () {
      expect(userProvider.role, equals(AppRole.sender));
      expect(userProvider.isAuthenticated, isFalse);
      expect(userProvider.walletBalance, equals(12450.00));
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

    test('Login updates phone and auth status', () {
      final success = userProvider.login('+8801712345678');
      expect(success, isTrue);
      expect(userProvider.isAuthenticated, isTrue);
      expect(userProvider.phone, equals('+8801712345678'));
      expect(userProvider.nidStatus, equals('verified'));
    });

    test('bKash and Nagad wallet top-ups increase balance', () {
      final initialBalance = userProvider.walletBalance;
      userProvider.topUpBkash(500.0);
      expect(userProvider.walletBalance, equals(initialBalance + 500.0));

      userProvider.topUpNagad(1000.0);
      expect(userProvider.walletBalance, equals(initialBalance + 1500.0));
      expect(userProvider.activityFeed.first, contains('Nagad'));
    });

    test('Deduct wallet locks funds into escrow', () {
      final initialBalance = userProvider.walletBalance;
      final initialEscrow = userProvider.escrowLockedBalance;

      final success = userProvider.deductWallet(450.0);
      expect(success, isTrue);
      expect(userProvider.walletBalance, equals(initialBalance - 450.0));
      expect(userProvider.escrowLockedBalance, equals(initialEscrow + 450.0));
    });

    test('Deduct wallet fails when balance is insufficient', () {
      final success = userProvider.deductWallet(999999.0);
      expect(success, isFalse);
    });

    test('Release escrow payout reduces locked balance', () {
      final initialEscrow = userProvider.escrowLockedBalance;
      userProvider.releaseEscrowPayout(500.0);
      expect(userProvider.escrowLockedBalance, equals(initialEscrow - 500.0));
    });
  });
}
