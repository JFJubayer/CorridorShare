import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/wallet/data/datasources/wallet_datasource.dart';
import 'package:corridorshare/features/wallet/data/models/wallet_transaction_dto.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:corridorshare/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(this._dataSource);

  final WalletDataSource _dataSource;

  @override
  Future<Result<Wallet>> getWallet(String userId) async {
    try {
      final wallet = await _dataSource.getWallet(userId);
      return Ok<Wallet>(wallet);
    } on Failure catch (f) {
      return Err<Wallet>(f);
    } catch (e) {
      return Err<Wallet>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<WalletTransaction>> topUp({
    required String userId,
    required double amount,
  }) async {
    try {
      final tx = await _dataSource.topUp(userId: userId, amount: amount);
      return Ok<WalletTransaction>(tx.toDomain());
    } on Failure catch (f) {
      return Err<WalletTransaction>(f);
    } catch (e) {
      return Err<WalletTransaction>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<WalletTransaction>> holdEscrow({
    required String userId,
    required double amount,
    required String referenceId,
    required String description,
  }) async {
    try {
      final tx = await _dataSource.holdEscrow(
        userId: userId,
        amount: amount,
        referenceId: referenceId,
        description: description,
      );
      return Ok<WalletTransaction>(tx.toDomain());
    } on Failure catch (f) {
      return Err<WalletTransaction>(f);
    } catch (e) {
      return Err<WalletTransaction>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<WalletTransaction>> releaseEscrow({
    required String senderId,
    required String travellerId,
    required double amount,
    required String referenceId,
  }) async {
    try {
      final tx = await _dataSource.releaseEscrow(
        senderId: senderId,
        travellerId: travellerId,
        amount: amount,
        referenceId: referenceId,
      );
      return Ok<WalletTransaction>(tx.toDomain());
    } on Failure catch (f) {
      return Err<WalletTransaction>(f);
    } catch (e) {
      return Err<WalletTransaction>(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<WalletTransaction>> refundEscrow({
    required String userId,
    required double amount,
    required String referenceId,
  }) async {
    try {
      final tx = await _dataSource.refundEscrow(
        userId: userId,
        amount: amount,
        referenceId: referenceId,
      );
      return Ok<WalletTransaction>(tx.toDomain());
    } on Failure catch (f) {
      return Err<WalletTransaction>(f);
    } catch (e) {
      return Err<WalletTransaction>(ServerFailure(e.toString()));
    }
  }
}
