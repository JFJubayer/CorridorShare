import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RaiseBudgetSheet extends ConsumerStatefulWidget {
  const RaiseBudgetSheet({
    required this.parcel,
    super.key,
  });

  final Parcel parcel;

  static Future<double?> show(
    BuildContext context, {
    required Parcel parcel,
  }) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF6F5EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => RaiseBudgetSheet(parcel: parcel),
    );
  }

  @override
  ConsumerState<RaiseBudgetSheet> createState() => _RaiseBudgetSheetState();
}

class _RaiseBudgetSheetState extends ConsumerState<RaiseBudgetSheet> {
  late final TextEditingController _budgetController;
  late List<int> _suggestedBudgets;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final current = widget.parcel.offeredPrice.toInt();
    final next = current + 50;
    _budgetController = TextEditingController(text: next.toString());
    _suggestedBudgets = [current + 50, current + 100, current + 150];
    _budgetController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final parsed = double.tryParse(_budgetController.text.trim());
    if (parsed == null || parsed <= widget.parcel.offeredPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount higher than current budget.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (mounted) {
      Navigator.of(context).pop(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAmount = int.tryParse(_budgetController.text.trim()) ?? 0;

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
          const Text(
            'Raise parcel budget',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.darkCharcoal,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current budget: ৳${widget.parcel.offeredPrice.toInt()} · Increase to attract more travellers',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6E786B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),

          // Input label
          const Text(
            'NEW BUDGET (BDT)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF7E867B),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),

          // Budget Input field
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
                    key: const Key('raiseBudgetField'),
                    controller: _budgetController,
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
          const SizedBox(height: 16),

          // Suggested price chips
          Row(
            children: _suggestedBudgets.map((price) {
              final isSelected = currentAmount == price;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    _budgetController.text = price.toString();
                    _budgetController.selection = TextSelection.fromPosition(
                      TextPosition(offset: _budgetController.text.length),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
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

          // Primary button: Raise budget
          FilledButton(
            key: const Key('confirmRaiseBudgetButton'),
            onPressed: _isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBDDC37),
              foregroundColor: AppColors.darkCharcoal,
              minimumSize: const Size.fromHeight(52),
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.darkCharcoal,
                    ),
                  )
                : const Text(
                    'Update budget',
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
