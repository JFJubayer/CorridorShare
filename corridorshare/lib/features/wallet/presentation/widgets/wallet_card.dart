import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:corridorshare/features/wallet/presentation/widgets/top_up_dialog.dart';
import 'package:corridorshare/features/wallet/presentation/widgets/transaction_history_sheet.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WalletCard extends ConsumerWidget {
  const WalletCard({
    required this.userId,
    super.key,
  });

  final String userId;

  void _openTopUp(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) => TopUpDialog(userId: userId),
    );
  }

  void _openHistory(BuildContext context, dynamic wallet) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.warmIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => TransactionHistorySheet(wallet: wallet),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final walletAsync = ref.watch(userWalletProvider(userId));

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: walletAsync.when(
          data: (wallet) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.bannerBg,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: AppColors.darkCharcoal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.walletDemoBalanceTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      key: const Key('walletLedgerButton'),
                      onPressed: () => _openHistory(context, wallet),
                      icon: const Icon(Icons.history, size: 16),
                      label: Text(
                        l10n.walletLedgerAction,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.darkCharcoal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.walletAvailableBalance,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ticketMutedText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳ ${wallet.balance.toStringAsFixed(0)}',
                            key: const Key('walletBalanceDisplay'),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.walletEscrowHold,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ticketMutedText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳ ${wallet.escrowBalance.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('openTopUpDialogButton'),
                    onPressed: () => _openTopUp(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.darkCharcoal,
                      foregroundColor: AppColors.limeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      minimumSize: const Size.fromHeight(46),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      l10n.walletTopUpAction,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(child: Text(err.toString())),
        ),
      ),
    );
  }
}
