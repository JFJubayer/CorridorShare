import 'package:corridorshare/features/wallet/data/models/wallet_transaction_dto.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet.dart';

abstract class WalletDataSource {
  Future<Wallet> getWallet(String userId);

  Future<WalletTransactionDto> topUp({
    required String userId,
    required double amount,
  });

  Future<WalletTransactionDto> holdEscrow({
    required String userId,
    required double amount,
    required String referenceId,
    required String description,
  });

  Future<WalletTransactionDto> releaseEscrow({
    required String senderId,
    required String travellerId,
    required double amount,
    required String referenceId,
  });

  Future<WalletTransactionDto> refundEscrow({
    required String userId,
    required double amount,
    required String referenceId,
  });
}
