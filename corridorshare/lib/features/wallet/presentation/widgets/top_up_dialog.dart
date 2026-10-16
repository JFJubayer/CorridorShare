import 'package:corridorshare/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopUpDialog extends ConsumerStatefulWidget {
  const TopUpDialog({
    required this.userId,
    super.key,
  });

  final String userId;

  @override
  ConsumerState<TopUpDialog> createState() => _TopUpDialogState();
}

class _TopUpDialogState extends ConsumerState<TopUpDialog> {
  final _amountController = TextEditingController(text: '1000');
  String? _errorMessage;

  static const List<double> _presetAmounts = <double>[500, 1000, 2000, 5000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      setState(() => _errorMessage = 'Enter a valid amount greater than 0');
      return;
    }

    setState(() => _errorMessage = null);

    final success = await ref
        .read(walletActionControllerProvider.notifier)
        .topUp(userId: widget.userId, amount: amount);

    if (mounted && success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final actionState = ref.watch(walletActionControllerProvider);

    return AlertDialog(
      title: Row(
        children: <Widget>[
          const Icon(Icons.account_balance_wallet, color: Colors.green),
          const SizedBox(width: 8),
          Text(l10n.walletTopUpTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.walletTopUpNotice, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _presetAmounts.map((preset) {
              return ChoiceChip(
                label: Text('৳${preset.toStringAsFixed(0)}'),
                selected: _amountController.text == preset.toStringAsFixed(0),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _amountController.text = preset.toStringAsFixed(0);
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('topUpAmountField'),
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.walletAmountLabel,
              prefixText: '৳ ',
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('submitTopUpButton'),
          onPressed: actionState.isLoading ? null : _submit,
          child: actionState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.walletTopUpAction),
        ),
      ],
    );
  }
}
