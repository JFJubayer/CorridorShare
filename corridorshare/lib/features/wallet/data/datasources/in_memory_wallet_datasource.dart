import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:corridorshare/features/wallet/data/models/wallet_transaction_dto.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet.dart';

class InMemoryWalletDataSource implements WalletDataSource {
  InMemoryWalletDataSource({
    Map<String, double>? initialBalances,
    Map<String, double>? initialEscrows,
    List<WalletTransactionDto>? initialTransactions,
  })  : _balances = initialBalances != null ? Map<String, double>.from(initialBalances) : <String, double>{},
        _escrows = initialEscrows != null ? Map<String, double>.from(initialEscrows) : <String, double>{},
        _transactions = initialTransactions != null ? List<WalletTransactionDto>.from(initialTransactions) : <WalletTransactionDto>[];

  final Map<String, double> _balances;
  final Map<String, double> _escrows;
  final List<WalletTransactionDto> _transactions;

  @override
  Future<Wallet> getWallet(String userId) async {
    final balance = _balances[userId] ?? 0.0;
    final escrow = _escrows[userId] ?? 0.0;
    final userTxs = _transactions
        .where((t) => t.userId == userId)
        .map((t) => t.toDomain())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Wallet(
      userId: userId,
      balance: balance,
      escrowBalance: escrow,
      transactions: userTxs,
    );
  }

  @override
  Future<WalletTransactionDto> topUp({
    required String userId,
    required double amount,
  }) async {
    final current = _balances[userId] ?? 0.0;
    _balances[userId] = current + amount;

    final now = DateTime.now();
    final tx = WalletTransactionDto(
      id: 'tx_${now.millisecondsSinceEpoch}',
      userId: userId,
      type: 'topUp',
      amount: amount,
      description: 'Demo wallet top-up',
      createdAt: now.toIso8601String(),
    );
    _transactions.insert(0, tx);
    return tx;
  }

  @override
  Future<WalletTransactionDto> holdEscrow({
    required String userId,
    required double amount,
    required String referenceId,
    required String description,
  }) async {
    final current = _balances[userId] ?? 0.0;
    if (current < amount) {
      throw const ValidationFailure(
        'Insufficient available wallet balance for escrow hold. Please top up your wallet.',
      );
    }

    _balances[userId] = current - amount;
    _escrows[userId] = (_escrows[userId] ?? 0.0) + amount;

    final now = DateTime.now();
    final tx = WalletTransactionDto(
      id: 'tx_${now.millisecondsSinceEpoch}',
      userId: userId,
      type: 'escrowHold',
      amount: amount,
      referenceId: referenceId,
      description: description,
      createdAt: now.toIso8601String(),
    );
    _transactions.insert(0, tx);
    return tx;
  }

  @override
  Future<WalletTransactionDto> releaseEscrow({
    required String senderId,
    required String travellerId,
    required double amount,
    required String referenceId,
  }) async {
    // Deduct from sender's escrow
    final senderEscrow = _escrows[senderId] ?? 0.0;
    _escrows[senderId] = (senderEscrow - amount).clamp(0.0, double.infinity);

    // Credit to traveller's available balance
    final travellerBal = _balances[travellerId] ?? 0.0;
    _balances[travellerId] = travellerBal + amount;

    final now = DateTime.now();
    final tx = WalletTransactionDto(
      id: 'tx_${now.millisecondsSinceEpoch}',
      userId: travellerId,
      type: 'escrowRelease',
      amount: amount,
      referenceId: referenceId,
      description: 'Delivery completed payment released',
      createdAt: now.toIso8601String(),
    );
    _transactions.insert(0, tx);
    return tx;
  }

  @override
  Future<WalletTransactionDto> refundEscrow({
    required String userId,
    required double amount,
    required String referenceId,
  }) async {
    final currentEscrow = _escrows[userId] ?? 0.0;
    _escrows[userId] = (currentEscrow - amount).clamp(0.0, double.infinity);

    final currentBal = _balances[userId] ?? 0.0;
    _balances[userId] = currentBal + amount;

    final now = DateTime.now();
    final tx = WalletTransactionDto(
      id: 'tx_${now.millisecondsSinceEpoch}',
      userId: userId,
      type: 'refund',
      amount: amount,
      referenceId: referenceId,
      description: 'Escrow refunded',
      createdAt: now.toIso8601String(),
    );
    _transactions.insert(0, tx);
    return tx;
  }
}
