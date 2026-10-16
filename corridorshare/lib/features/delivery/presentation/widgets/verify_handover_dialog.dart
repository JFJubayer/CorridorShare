import 'package:corridorshare/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyHandoverDialog extends ConsumerStatefulWidget {
  const VerifyHandoverDialog({
    required this.deliveryId,
    super.key,
  });

  final String deliveryId;

  @override
  ConsumerState<VerifyHandoverDialog> createState() =>
      _VerifyHandoverDialogState();
}

class _VerifyHandoverDialogState extends ConsumerState<VerifyHandoverDialog> {
  final _pinController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4 || int.tryParse(pin) == null) {
      setState(() {
        _errorMessage = 'Please enter a valid 4-digit numeric PIN';
      });
      return;
    }

    setState(() => _errorMessage = null);

    final success = await ref
        .read(deliveryActionControllerProvider.notifier)
        .verifyDelivery(
          deliveryId: widget.deliveryId,
          inputPin: pin,
        );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        final error = ref.read(deliveryActionControllerProvider).error;
        setState(() {
          _errorMessage = error != null
              ? error.toString().replaceFirst('Exception: ', '')
              : 'Verification failed. Incorrect PIN.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final actionState = ref.watch(deliveryActionControllerProvider);

    return AlertDialog(
      title: Row(
        children: <Widget>[
          const Icon(Icons.verified_user_outlined, color: Colors.green),
          const SizedBox(width: 8),
          Text(l10n.verifyDeliveryTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.verifyDeliveryHint,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('handoverPinField'),
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              letterSpacing: 12,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: '••••',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
          key: const Key('submitHandoverPinButton'),
          onPressed: actionState.isLoading ? null : _submit,
          child: actionState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.verifyAndComplete),
        ),
      ],
    );
  }
}
