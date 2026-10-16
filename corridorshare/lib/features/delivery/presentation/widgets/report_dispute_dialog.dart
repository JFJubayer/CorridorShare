import 'package:corridorshare/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportDisputeDialog extends ConsumerStatefulWidget {
  const ReportDisputeDialog({
    required this.deliveryId,
    required this.currentUserId,
    super.key,
  });

  final String deliveryId;
  final String currentUserId;

  @override
  ConsumerState<ReportDisputeDialog> createState() =>
      _ReportDisputeDialogState();
}

class _ReportDisputeDialogState extends ConsumerState<ReportDisputeDialog> {
  final _reasonController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _errorMessage = l10n.disputeReasonRequired);
      return;
    }

    final success = await ref
        .read(deliveryActionControllerProvider.notifier)
        .reportDispute(
          deliveryId: widget.deliveryId,
          reason: reason,
          reporterId: widget.currentUserId,
        );

    if (mounted && success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actionState = ref.watch(deliveryActionControllerProvider);

    return AlertDialog(
      title: Row(
        children: <Widget>[
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 8),
          Text(l10n.reportDisputeTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.reportDisputeHint),
          const SizedBox(height: 12),
          TextField(
            key: const Key('disputeReasonField'),
            controller: _reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.disputeReasonExampleHint,
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
          key: const Key('submitDisputeButton'),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: actionState.isLoading ? null : _submit,
          child: actionState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.statusDisputed),
        ),
      ],
    );
  }
}
