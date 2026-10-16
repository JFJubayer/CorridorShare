import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/presentation/providers/delivery_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickupHandoverSheet extends ConsumerStatefulWidget {
  const PickupHandoverSheet({
    required this.delivery,
    super.key,
  });

  final Delivery delivery;

  @override
  ConsumerState<PickupHandoverSheet> createState() =>
      _PickupHandoverSheetState();
}

class _PickupHandoverSheetState extends ConsumerState<PickupHandoverSheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final String _photoUrl =
      'https://images.unsplash.com/photo-1549465220-1a8b9238cd48';
  bool _inspectedCondition = true;
  bool _noProhibitedItems = true;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (!_inspectedCondition || !_noProhibitedItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.verifyConditionChecklistPrompt),
        ),
      );
      return;
    }

    final success = await ref
        .read(deliveryActionControllerProvider.notifier)
        .confirmPickup(
          deliveryId: widget.delivery.id,
          photoUrl: _photoUrl,
          notes: _notesController.text.trim().isEmpty
              ? l10n.defaultPickupInspectedNote
              : _notesController.text.trim(),
        );

    if (mounted && success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final actionState = ref.watch(deliveryActionControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    l10n.pickupHandoverTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                '${widget.delivery.parcelTitle} (${widget.delivery.fromDistrict} → ${widget.delivery.toDistrict})',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Photo Proof Preview
              Text(
                l10n.pickupPhotoProofLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Icon(Icons.camera_alt, size: 36, color: Colors.blueGrey),
                      const SizedBox(height: 6),
                      Text(
                        l10n.pickupPhotoCaptured,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'demo_parcel_pickup_proof.jpg',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Condition Checkboxes
              CheckboxListTile(
                value: _inspectedCondition,
                onChanged: (v) => setState(() => _inspectedCondition = v ?? false),
                title: Text(l10n.pickupCheckCondition),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                value: _noProhibitedItems,
                onChanged: (v) => setState(() => _noProhibitedItems = v ?? false),
                title: Text(l10n.pickupCheckNoLeaks),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),

              // Notes input
              TextField(
                key: const Key('pickupNotesField'),
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.pickupNotesHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('confirmPickupButton'),
                  onPressed: actionState.isLoading ? null : _submit,
                  icon: actionState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(l10n.confirmPickupAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
