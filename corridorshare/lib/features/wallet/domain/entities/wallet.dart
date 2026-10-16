import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.freezed.dart';

@freezed
abstract class Wallet with _$Wallet {
  const factory Wallet({
    required String userId,
    required double balance,
    required double escrowBalance,
    @Default(<WalletTransaction>[]) List<WalletTransaction> transactions,
  }) = _Wallet;
}
