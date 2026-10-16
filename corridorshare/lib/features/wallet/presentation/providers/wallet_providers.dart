import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet.dart';
import 'package:corridorshare/features/wallet/domain/usecases/top_up_wallet.dart';
import 'package:corridorshare/features/wallet/domain/usecases/wallet_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:corridorshare/core/di/injection.dart'
    show walletDataSourceProvider, walletRepositoryProvider;

final topUpWalletUseCaseProvider = Provider<TopUpWallet>((ref) {
  return TopUpWallet(ref.watch(walletRepositoryProvider));
});

final holdEscrowUseCaseProvider = Provider<HoldEscrow>((ref) {
  return HoldEscrow(ref.watch(walletRepositoryProvider));
});

final releaseEscrowUseCaseProvider = Provider<ReleaseEscrow>((ref) {
  return ReleaseEscrow(ref.watch(walletRepositoryProvider));
});

final refundEscrowUseCaseProvider = Provider<RefundEscrow>((ref) {
  return RefundEscrow(ref.watch(walletRepositoryProvider));
});

final getWalletUseCaseProvider = Provider<GetWallet>((ref) {
  return GetWallet(ref.watch(walletRepositoryProvider));
});

final userWalletProvider =
    FutureProvider.family<Wallet, String>((ref, userId) async {
  final result = await ref.watch(getWalletUseCaseProvider)(userId);
  return result.fold(
    (wallet) => wallet,
    (failure) => throw failure,
  );
});

class WalletActionController extends StateNotifier<AsyncValue<void>> {
  WalletActionController(this._ref) : super(const AsyncValue<void>.data(null));

  final Ref _ref;

  Future<bool> topUp({
    required String userId,
    required double amount,
  }) async {
    state = const AsyncValue<void>.loading();
    final result = await _ref.read(topUpWalletUseCaseProvider)(
      userId: userId,
      amount: amount,
    );
    return result.fold(
      (_) {
        state = const AsyncValue<void>.data(null);
        _ref.invalidate(userWalletProvider(userId));
        return true;
      },
      (failure) {
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return false;
      },
    );
  }
}

final walletActionControllerProvider =
    StateNotifierProvider<WalletActionController, AsyncValue<void>>((ref) {
  return WalletActionController(ref);
});
