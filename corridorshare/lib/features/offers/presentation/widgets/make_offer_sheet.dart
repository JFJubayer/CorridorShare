import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:corridorshare/features/offers/presentation/providers/offer_providers.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MakeOfferSheet extends ConsumerStatefulWidget {
  const MakeOfferSheet({
    required this.trip,
    required this.parcel,
    required this.currentUserId,
    super.key,
  });

  final Trip trip;
  final Parcel parcel;
  final String currentUserId;

  @override
  ConsumerState<MakeOfferSheet> createState() => _MakeOfferSheetState();
}

class _MakeOfferSheetState extends ConsumerState<MakeOfferSheet> {
  late final TextEditingController _priceController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.parcel.offeredPrice.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final now = DateTime.now();
    final isSender = widget.currentUserId == widget.parcel.senderId;
    final initialStatus =
        isSender ? OfferStatus.pendingTraveller : OfferStatus.pendingSender;

    final offer = Offer(
      id: 'offer_${now.millisecondsSinceEpoch}',
      parcelId: widget.parcel.id,
      tripId: widget.trip.id,
      senderId: widget.parcel.senderId,
      senderName: widget.parcel.senderName,
      travellerId: widget.trip.travellerId,
      travellerName: widget.trip.travellerName,
      parcelTitle: widget.parcel.title,
      fromDistrict: widget.parcel.fromDistrict,
      toDistrict: widget.parcel.toDistrict,
      price: price,
      status: initialStatus,
      lastCounterBy: widget.currentUserId,
      createdAt: now,
      updatedAt: now,
    );

    final success = await ref
        .read(offerActionControllerProvider.notifier)
        .createOffer(offer);

    if (mounted && success) {
      Navigator.of(context).pop();
      await context.push('${AppRoutes.chats}/${offer.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(offerActionControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  l10n.makeOffer,
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

            // Corridor summary
            Text(
              '${widget.parcel.title} (${widget.parcel.fromDistrict} → ${widget.parcel.toDistrict})',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Traveller No-Carry Warning Banner (Mandatory per brief)
            if (widget.trip.noCarryTags.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.warning_amber_rounded,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l10n.noCarryAlert}${widget.trip.noCarryTags.join(", ")}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Proposed price input
            TextFormField(
              key: const Key('offerPriceField'),
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.offerPrice,
                prefixText: '৳ ',
                border: const OutlineInputBorder(),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return l10n.enterPriceError;
                final parsed = double.tryParse(val.trim());
                if (parsed == null || parsed <= 0) return l10n.priceMustBePositive;
                return null;
              },
            ),

            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),

            const SizedBox(height: 20),

            FilledButton.icon(
              key: const Key('submitOfferButton'),
              onPressed: state.isLoading ? null : _submit,
              icon: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.handshake),
              label: Text(l10n.makeOffer),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
