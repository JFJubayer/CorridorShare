import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
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
  late final List<int> _suggestedPrices;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final defaultPrice = widget.parcel.offeredPrice.round();
    _priceController = TextEditingController(text: defaultPrice.toString());
    _suggestedPrices = _calculateSuggestions(defaultPrice);
    _priceController.addListener(() {
      setState(() {});
    });
  }

  List<int> _calculateSuggestions(int basePrice) {
    final lower = basePrice > 50 ? basePrice - 50 : (basePrice * 0.8).round();
    final middle = basePrice;
    final higher = basePrice + 50;
    final set = <int>{lower, middle, higher}..removeWhere((p) => p <= 0);
    final list = set.toList()..sort();
    return list;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '??';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
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
      final router = GoRouter.maybeOf(context);
      Navigator.of(context).pop(offer);
      if (router != null) {
        await router.push('${AppRoutes.chats}/${offer.id}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(offerActionControllerProvider);
    final currentPriceInt = int.tryParse(_priceController.text.trim()) ?? 0;
    final senderInitials = _getInitials(widget.parcel.senderName);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top pill handle matching other sheets
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0CDC2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'OFFER TO CARRY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7E867B),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.makeOffer,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkCharcoal,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.darkCharcoal,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Parcel & Corridor Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE8E6DB),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 19,
                          backgroundColor: const Color(0xFFF0ECE1),
                          child: Text(
                            senderInitials,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${widget.parcel.title} · ${widget.parcel.weightKg.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkCharcoal,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sender: ${widget.parcel.senderName}',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF6E786B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            const Text(
                              'LISTED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF7E867B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '৳${widget.parcel.offeredPrice.toInt()}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F5EE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.route_outlined,
                            size: 15,
                            color: Color(0xFF6E786B),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${widget.parcel.fromDistrict} → ${widget.parcel.toDistrict}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Traveller No-Carry Warning Banner (Mandatory per brief & tests)
              if (widget.trip.noCarryTags.isNotEmpty) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE8E7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFF1C1BD),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFB03A2E),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n.noCarryAlert}${widget.trip.noCarryTags.join(", ")}',
                          style: const TextStyle(
                            color: Color(0xFF942F24),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Proposed Price Input Section
              const Text(
                'YOUR PROPOSED PRICE (BDT)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7E867B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFBF8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.darkCharcoal,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Text(
                      '৳',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        key: const Key('offerPriceField'),
                        controller: _priceController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkCharcoal,
                          letterSpacing: -0.5,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          errorStyle: TextStyle(fontSize: 11, height: 1.1),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return l10n.enterPriceError;
                          }
                          final parsed = double.tryParse(val.trim());
                          if (parsed == null || parsed <= 0) {
                            return l10n.priceMustBePositive;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Suggested quick price pills
              Row(
                children: _suggestedPrices.map((price) {
                  final isSelected = currentPriceInt == price;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      key: Key('priceChip_$price'),
                      onTap: () {
                        _priceController.text = price.toString();
                        _priceController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _priceController.text.length),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFBDDC37)
                              : const Color(0xFFEBE8DC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '৳$price',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),

              // Helper caption
              const Text(
                'Fair prices get accepted faster.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF7E867B),
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 22),

              // Submit Button: Full-width StadiumBorder with handshake icon
              FilledButton(
                key: const Key('submitOfferButton'),
                onPressed: state.isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF16211A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.handshake_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.makeOffer,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
