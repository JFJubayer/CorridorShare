import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:corridorshare/features/wallet/domain/repositories/wallet_repository.dart';

class HoldEscrow {
  const HoldEscrow(this._repository);

  final WalletRepository _repository;

  Future<Result<WalletTransaction>> call({
    required String userId,
    required double amount,
    required String referenceId,
    required String description,
  }) async {
    if (amount <= 0) {
      return const Err<WalletTransaction>(
        ValidationFailure('Escrow amount must be positive'),
      );
    }
    return _repository.holdEscrow(
      userId: userId,
      amount: amount,
      referenceId: referenceId,
      description: description,
    );
  }
}

class ReleaseEscrow {
  const ReleaseEscrow(this._repository);

  final WalletRepository _repository;

  Future<Result<WalletTransaction>> call({
    required String senderId,
    required String travellerId,
    required double amount,
    required String referenceId,
  }) async {
    if (amount <= 0) {
      return const Err<WalletTransaction>(
        ValidationFailure('Release amount must be positive'),
      );
    }
    return _repository.releaseEscrow(
      senderId: senderId,
      travellerId: travellerId,
      amount: amount,
      referenceId: referenceId,
    );
  }
}

class RefundEscrow {
  const RefundEscrow(this._repository);

  final WalletRepository _repository;

  Future<Result<WalletTransaction>> call({
    required String userId,
    required double amount,
    required String referenceId,
  }) async {
    if (amount <= 0) {
      return const Err<WalletTransaction>(
        ValidationFailure('Refund amount must be positive'),
      );
    }
    return _repository.refundEscrow(
      userId: userId,
      amount: amount,
      referenceId: referenceId,
    );
  }
}

class GetWallet {
  const GetWallet(this._repository);

  final WalletRepository _repository;

  Future<Result<Wallet>> call(String userId) {
    return _repository.getWallet(userId);
  }
}
