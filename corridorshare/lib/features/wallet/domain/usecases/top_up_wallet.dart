import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:corridorshare/features/wallet/domain/repositories/wallet_repository.dart';

class TopUpWallet {
  const TopUpWallet(this._repository);

  final WalletRepository _repository;

  Future<Result<WalletTransaction>> call({
    required String userId,
    required double amount,
  }) async {
    if (amount <= 0) {
      return const Err<WalletTransaction>(
        ValidationFailure('Top-up amount must be greater than 0 BDT'),
      );
    }
    if (amount > 50000) {
      return const Err<WalletTransaction>(
        ValidationFailure('Maximum demo top-up per transaction is ৳50,000'),
      );
    }
    return _repository.topUp(userId: userId, amount: amount);
  }
}
