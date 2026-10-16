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
      builder: (context) => TransactionHistorySheet(wallet: wallet),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final walletAsync = ref.watch(userWalletProvider(userId));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
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
                        Icon(
                          Icons.account_balance_wallet,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.walletDemoBalanceTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      key: const Key('walletLedgerButton'),
                      onPressed: () => _openHistory(context, wallet),
                      icon: const Icon(Icons.history, size: 16),
                      label: Text(l10n.walletLedgerAction),
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
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳ ${wallet.balance.toStringAsFixed(0)}',
                            key: const Key('walletBalanceDisplay'),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
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
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '৳ ${wallet.escrowBalance.toStringAsFixed(0)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
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
                  child: FilledButton.tonalIcon(
                    key: const Key('openTopUpDialogButton'),
                    onPressed: () => _openTopUp(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.walletTopUpAction),
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
