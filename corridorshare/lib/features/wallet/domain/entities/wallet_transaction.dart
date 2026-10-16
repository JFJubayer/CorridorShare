import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_transaction.freezed.dart';

@freezed
abstract class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required String id,
    required String userId,
    required WalletTransactionType type,
    required double amount,
    String? referenceId,
    required String description,
    required DateTime createdAt,
  }) = _WalletTransaction;
}
