import 'package:corridorshare/features/wallet/domain/entities/wallet.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionHistorySheet extends StatelessWidget {
  const TransactionHistorySheet({
    required this.wallet,
    super.key,
  });

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.walletLedgerTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (wallet.transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  l10n.walletNoTransactions,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: wallet.transactions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final tx = wallet.transactions[index];
                  final isCredit = tx.type.isCredit;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: isCredit
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isCredit ? Colors.green : Colors.orange,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      tx.description,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      dateFormat.format(tx.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: Text(
                      '${isCredit ? "+" : "-"}৳${tx.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCredit ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
