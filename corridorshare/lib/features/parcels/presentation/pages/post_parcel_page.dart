import 'package:corridorshare/core/presentation/widgets/route_selector_card.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_size.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PostParcelPage extends ConsumerStatefulWidget {
  const PostParcelPage({super.key});

  @override
  ConsumerState<PostParcelPage> createState() => _PostParcelPageState();
}

class _PostParcelPageState extends ConsumerState<PostParcelPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  String? _fromDistrict = 'Dhaka';
  String? _toDistrict = 'Chattogram';
  final TextEditingController _fromAreaController = TextEditingController();
  final TextEditingController _toAreaController = TextEditingController();
  final TextEditingController _weightController =
      TextEditingController(text: '1.0');
  final TextEditingController _priceController =
      TextEditingController(text: '500');

  ParcelSize _size = ParcelSize.medium;
  DateTime _deadline = DateTime.now().add(const Duration(days: 3));
  bool _prohibitedDeclared = false;
  final Set<String> _selectedTags = <String>{'documents'};

  static const List<String> _suggestedTags = <String>[
    'documents',
    'electronics',
    'clothes',
    'books',
    'gift',
    'fragile',
  ];

  static const Map<String, String> _tagDisplayNames = <String, String>{
    'documents': 'Documents',
    'electronics': 'Electronics',
    'clothes': 'Clothes',
    'books': 'Books',
    'gift': 'Gift',
    'fragile': 'Fragile',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _fromAreaController.dispose();
    _toAreaController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _swapRoute() {
    setState(() {
      final String? tempDistrict = _fromDistrict;
      _fromDistrict = _toDistrict;
      _toDistrict = tempDistrict;

      final String tempArea = _fromAreaController.text;
      _fromAreaController.text = _toAreaController.text;
      _toAreaController.text = tempArea;
    });
  }

  void _incrementWeight() {
    final double cur = double.tryParse(_weightController.text.trim()) ?? 1.0;
    if (cur < 50.0) {
      setState(() {
        _weightController.text = (cur + 0.5).toStringAsFixed(1);
      });
    }
  }

  void _decrementWeight() {
    final double cur = double.tryParse(_weightController.text.trim()) ?? 1.0;
    if (cur > 0.5) {
      setState(() {
        _weightController.text = (cur - 0.5).toStringAsFixed(1);
      });
    }
  }

  Future<void> _pickDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkCharcoal,
              onPrimary: Colors.white,
              surface: AppColors.warmIvory,
              onSurface: AppColors.darkCharcoal,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_prohibitedDeclared) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You must acknowledge the prohibited items declaration.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final double weight =
        double.tryParse(_weightController.text.trim()) ?? 0.0;
    final double price =
        double.tryParse(_priceController.text.trim()) ?? 0.0;
    final DateTime now = DateTime.now();

    final currentUser = ref.read(currentUserProvider);
    final String senderId = currentUser?.id ?? '';
    final String senderName = currentUser != null && currentUser.name.isNotEmpty
        ? currentUser.name
        : (currentUser != null && currentUser.email.isNotEmpty
            ? currentUser.email.split('@').first
            : 'User');

    final Parcel parcel = Parcel(
      id: 'parcel_${now.millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      title: _titleController.text.trim(),
      fromDistrict: _fromDistrict!,
      fromArea: _fromAreaController.text.trim(),
      toDistrict: _toDistrict!,
      toArea: _toAreaController.text.trim(),
      categoryTags: _selectedTags.toList(),
      weightKg: weight,
      size: _size,
      deadline: _deadline,
      offeredPrice: price,
      status: ParcelStatus.open,
      hasProhibitedItemsDeclaration: _prohibitedDeclared,
      note: null,
      createdAt: now,
    );

    final bool success = await ref
        .read(postParcelControllerProvider.notifier)
        .submitParcel(parcel);

    if (mounted && success) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.parcelCreatedSuccess),
          backgroundColor: Colors.green,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final state = ref.watch(postParcelControllerProvider);
    final DateFormat deadlineFormat = DateFormat('EEE, d MMM');

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: <Widget>[
              // Top Bar: Back Arrow + Title
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.darkCharcoal,
                      size: 24,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.postParcelTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // "What are you sending?" Container
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(27),
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 20,
                      color: AppColors.darkCharcoal,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        key: const Key('parcelTitleField'),
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkCharcoal,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'What are you sending?',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.ticketMutedText,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                          fillColor: Colors.transparent,
                        ),
                        validator: (String? val) =>
                            val == null || val.trim().isEmpty
                                ? 'Enter item name'
                                : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Route Card (From / To + Areas + Swap)
              RouteSelectorCard(
                fromDistrict: _fromDistrict,
                toDistrict: _toDistrict,
                fromAreaController: _fromAreaController,
                toAreaController: _toAreaController,
                onFromDistrictChanged: (String? val) {
                  setState(() => _fromDistrict = val);
                },
                onToDistrictChanged: (String? val) {
                  setState(() => _toDistrict = val);
                },
                onSwap: _swapRoute,
                fromDistrictValidator: (String? val) =>
                    val == null ? 'Please select origin district' : null,
                toDistrictValidator: (String? val) {
                  if (val == null) return 'Please select destination district';
                  if (val == _fromDistrict) {
                    return 'Destination must differ from origin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Section
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedTags.map((String tag) {
                  final bool isSelected = _selectedTags.contains(tag);
                  final String displayName = _tagDisplayNames[tag] ?? tag;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSelected ? 14 : 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.limeAccent
                            : AppColors.pillInactive,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (isSelected) ...<Widget>[
                            const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.darkCharcoal,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Two columns: WEIGHT and SIZE
              Row(
                children: <Widget>[
                  // Weight Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'WEIGHT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ticketMutedText,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              InkWell(
                                onTap: _decrementWeight,
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Icon(
                                    Icons.remove,
                                    size: 18,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  key: const Key('parcelWeightField'),
                                  controller: _weightController,
                                  textAlign: TextAlign.center,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkCharcoal,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    suffixText: ' kg',
                                    suffixStyle: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkCharcoal,
                                    ),
                                  ),
                                  validator: (String? val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Enter weight';
                                    }
                                    final double? parsed =
                                        double.tryParse(val.trim());
                                    if (parsed == null || parsed <= 0) {
                                      return '> 0 kg';
                                    }
                                    if (parsed > 50) {
                                      return '≤ 50 kg';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: _incrementWeight,
                                borderRadius: BorderRadius.circular(20),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 18,
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
                  const SizedBox(width: 14),

                  // Size Capsule Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'SIZE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ticketMutedText,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1.2,
                            ),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            children: <Widget>[
                              _buildSizeItem(ParcelSize.small, 'S'),
                              _buildSizeItem(ParcelSize.medium, 'M'),
                              _buildSizeItem(ParcelSize.large, 'L'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Two columns: REWARD (BDT) and DELIVER BEFORE
              Row(
                children: <Widget>[
                  // Reward Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'REWARD (BDT)',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ticketMutedText,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1.2,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[
                              const Text(
                                '৳ ',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkCharcoal,
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  key: const Key('parcelPriceField'),
                                  controller: _priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkCharcoal,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                  ),
                                  validator: (String? val) {
                                    if (val == null || val.trim().isEmpty) {
                                      return 'Enter reward';
                                    }
                                    final double? parsed =
                                        double.tryParse(val.trim());
                                    if (parsed == null || parsed <= 0) {
                                      return 'Must be > 0 BDT';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Deliver Before Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'DELIVER BEFORE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ticketMutedText,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDeadline,
                          borderRadius: BorderRadius.circular(26),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: AppColors.cardBorder,
                                width: 1.2,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 18,
                                  color: AppColors.darkCharcoal,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    deadlineFormat.format(_deadline),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkCharcoal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Prohibited items declaration card
              Material(
                color: const Color(0xFFF1EFE6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(
                    color: Color(0xFFE5E2D6),
                    width: 1.2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: CheckboxListTile(
                    key: const Key('prohibitedDeclarationCheckbox'),
                    value: _prohibitedDeclared,
                    onChanged: (bool? val) =>
                        setState(() => _prohibitedDeclared = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    activeColor: AppColors.darkCharcoal,
                    checkColor: AppColors.limeAccent,
                    title: Text(
                      'I confirm this parcel contains no illegal, contraband or prohibited items.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkCharcoal.withValues(alpha: 0.85),
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error banner if any
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Submit Button: Pill Post parcel button
              ElevatedButton(
                key: const Key('submitParcelButton'),
                onPressed: state.isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkCharcoal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Post parcel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeItem(ParcelSize size, String label) {
    final bool isSelected = _size == size;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _size = size),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.limeAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? AppColors.darkCharcoal
                  : AppColors.ticketMutedText,
            ),
          ),
        ),
      ),
    );
  }
}
