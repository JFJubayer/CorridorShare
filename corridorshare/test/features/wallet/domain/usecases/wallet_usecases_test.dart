import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/wallet/data/datasources/in_memory_wallet_datasource.dart';
import 'package:corridorshare/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:corridorshare/features/wallet/domain/usecases/top_up_wallet.dart';
import 'package:corridorshare/features/wallet/domain/usecases/wallet_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryWalletDataSource dataSource;
  late WalletRepositoryImpl repository;
  late TopUpWallet topUpWallet;
  late HoldEscrow holdEscrow;
  late ReleaseEscrow releaseEscrow;
  late RefundEscrow refundEscrow;
  late GetWallet getWallet;

  setUp(() {
    dataSource = InMemoryWalletDataSource(
      initialBalances: {'user-a': 1000.0, 'user-b': 500.0},
      initialEscrows: {'user-a': 0.0, 'user-b': 0.0},
    );
    repository = WalletRepositoryImpl(dataSource);
    topUpWallet = TopUpWallet(repository);
    holdEscrow = HoldEscrow(repository);
    releaseEscrow = ReleaseEscrow(repository);
    refundEscrow = RefundEscrow(repository);
    getWallet = GetWallet(repository);
  });

  group('TopUpWallet', () {
    test('fails if top-up amount is non-positive', () async {
      final res = await topUpWallet(userId: 'user-a', amount: 0);
      expect(res, isA<Err>());
    });

    test('fails if top-up amount exceeds maximum 50,000 limit', () async {
      final res = await topUpWallet(userId: 'user-a', amount: 60000);
      expect(res, isA<Err>());
    });

    test('credits user balance on valid top-up', () async {
      final res = await topUpWallet(userId: 'user-a', amount: 1500);
      expect(res, isA<Ok>());

      final wallet = await getWallet('user-a');
      expect(wallet.getOrThrow().balance, 2500.0);
    });
  });

  group('HoldEscrow', () {
    test('fails when user has insufficient balance', () async {
      final res = await holdEscrow(
        userId: 'user-a',
        amount: 2000, // available is only 1000
        referenceId: 'delivery-1',
        description: 'Escrow hold',
      );
      expect(res, isA<Err>());
    });

    test('deducts available balance and increases escrow balance', () async {
      final res = await holdEscrow(
        userId: 'user-a',
        amount: 400,
        referenceId: 'delivery-1',
        description: 'Escrow hold',
      );
      expect(res, isA<Ok>());

      final wallet = await getWallet('user-a');
      expect(wallet.getOrThrow().balance, 600.0);
      expect(wallet.getOrThrow().escrowBalance, 400.0);
    });
  });

  group('ReleaseEscrow', () {
    test('deducts sender escrow and credits traveller balance', () async {
      // Hold escrow first
      await holdEscrow(
        userId: 'user-a',
        amount: 400,
        referenceId: 'delivery-1',
        description: 'Escrow hold',
      );

      final res = await releaseEscrow(
        senderId: 'user-a',
        travellerId: 'user-b',
        amount: 400,
        referenceId: 'delivery-1',
      );
      expect(res, isA<Ok>());

      final senderWallet = await getWallet('user-a');
      expect(senderWallet.getOrThrow().escrowBalance, 0.0);

      final travellerWallet = await getWallet('user-b');
      expect(travellerWallet.getOrThrow().balance, 900.0); // 500 + 400
    });
  });

  group('RefundEscrow', () {
    test('reverts escrow hold back to user available balance', () async {
      await holdEscrow(
        userId: 'user-a',
        amount: 400,
        referenceId: 'delivery-1',
        description: 'Escrow hold',
      );

      final res = await refundEscrow(
        userId: 'user-a',
        amount: 400,
        referenceId: 'delivery-1',
      );
      expect(res, isA<Ok>());

      final wallet = await getWallet('user-a');
      expect(wallet.getOrThrow().balance, 1000.0);
      expect(wallet.getOrThrow().escrowBalance, 0.0);
    });
  });
}
