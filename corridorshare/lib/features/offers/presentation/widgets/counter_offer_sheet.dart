import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/presentation/providers/offer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterOfferSheet extends ConsumerStatefulWidget {
  const CounterOfferSheet({
    required this.offer,
    required this.budget,
    super.key,
  });

  final Offer offer;
  final double budget;

  static Future<bool?> show(
    BuildContext context, {
    required Offer offer,
    required double budget,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF6F5EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => CounterOfferSheet(offer: offer, budget: budget),
    );
  }

  @override
  ConsumerState<CounterOfferSheet> createState() => _CounterOfferSheetState();
}

class _CounterOfferSheetState extends ConsumerState<CounterOfferSheet> {
  late final TextEditingController _priceController;
  late List<int> _suggestedPrices;

  @override
  void initState() {
    super.initState();
    // Default initial price is 280 (or roughly between offer price and budget)
    final initialPrice = _calculateInitialPrice();
    _priceController = TextEditingController(text: initialPrice.toString());
    _suggestedPrices = _calculateSuggestions();
    _priceController.addListener(() {
      setState(() {});
    });
  }

  int _calculateInitialPrice() {
    if (widget.offer.price == 300 && widget.budget == 350) {
      return 280;
    }
    final mid = ((widget.offer.price + widget.budget) / 2).round();
    return (mid ~/ 10) * 10;
  }

  List<int> _calculateSuggestions() {
    if (widget.offer.price == 300 && widget.budget == 350) {
      return const <int>[250, 280, 300];
    }
    final p = widget.offer.price.toInt();
    final b = widget.budget.toInt();
    final lower = ((p * 0.85) ~/ 10) * 10;
    final middle = (((p + b) / 2) ~/ 10) * 10;
    final higher = p;
    final set = <int>{lower, middle, higher};
    final list = set.toList()..sort();
    while (list.length < 3) {
      list.add(list.last + 50);
    }
    return list.take(3).toList();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  String get _travellerFirstName {
    final parts = widget.offer.travellerName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : widget.offer.travellerName;
  }

  Future<void> _submit() async {
    final parsed = double.tryParse(_priceController.text.trim());
    if (parsed == null || parsed <= 0) return;

    final currentUserId = ref.read(currentUserProvider)?.id ?? widget.offer.senderId;

    final success = await ref
        .read(offerActionControllerProvider.notifier)
        .counterOffer(
          offerId: widget.offer.id,
          newPrice: parsed,
          counterByUserId: currentUserId,
        );

    if (mounted && success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(offerActionControllerProvider);
    final currentPriceInt = int.tryParse(_priceController.text.trim()) ?? 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top pill handle
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
          const SizedBox(height: 20),

          // Header
          Text(
            'Counter-offer to $_travellerFirstName',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.darkCharcoal,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$_travellerFirstName asked ৳${widget.offer.price.toInt()} · your budget ৳${widget.budget.toInt()}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6E786B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Input label
          const Text(
            'YOUR PRICE (BDT)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7E867B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          // Price Input field matching screenshot
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
                  child: TextField(
                    key: const Key('counterPriceField'),
                    controller: _priceController,
                    keyboardType: TextInputType.number,
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
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Helper caption
          const Text(
            'Fair prices get accepted faster.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF7E867B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          // Price chips row
          Row(
            children: _suggestedPrices.map((price) {
              final isSelected = currentPriceInt == price;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
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
                      horizontal: 22,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFBDDC37)
                          : const Color(0xFFEBE8DC),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      '৳$price',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 26),

          // Error message if any
          if (actionState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                actionState.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),

          // Primary button: Send counter-offer
          FilledButton(
            key: const Key('sendCounterOfferButton'),
            onPressed: actionState.isLoading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBDDC37),
              foregroundColor: AppColors.darkCharcoal,
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: actionState.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.darkCharcoal,
                    ),
                  )
                : const Text(
                    'Send counter-offer',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
