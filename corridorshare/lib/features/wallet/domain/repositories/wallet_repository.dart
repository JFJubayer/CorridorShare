import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction.dart';

abstract class WalletRepository {
  Future<Result<Wallet>> getWallet(String userId);

  Future<Result<WalletTransaction>> topUp({
    required String userId,
    required double amount,
  });

  Future<Result<WalletTransaction>> holdEscrow({
    required String userId,
    required double amount,
    required String referenceId,
    required String description,
  });

  Future<Result<WalletTransaction>> releaseEscrow({
    required String senderId,
    required String travellerId,
    required double amount,
    required String referenceId,
  });

  Future<Result<WalletTransaction>> refundEscrow({
    required String userId,
    required double amount,
    required String referenceId,
  });
}
