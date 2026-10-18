import 'package:corridorshare/core/presentation/widgets/route_selector_card.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PostTripPage extends ConsumerStatefulWidget {
  const PostTripPage({super.key});

  @override
  ConsumerState<PostTripPage> createState() => _PostTripPageState();
}

class _PostTripPageState extends ConsumerState<PostTripPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? _fromDistrict = 'Dhaka';
  String? _toDistrict = 'Chattogram';
  final TextEditingController _fromAreaController = TextEditingController();
  final TextEditingController _toAreaController = TextEditingController();
  final TextEditingController _capacityController =
      TextEditingController(text: '5.0');
  final TextEditingController _noteController = TextEditingController();

  DateTime _departureDate = DateTime.now().add(const Duration(days: 1));
  final Set<String> _noCarryTags = <String>{'liquids', 'perishable_food'};

  static const List<String> _commonTags = <String>[
    'liquids',
    'perishable_food',
    'electronics',
    'fragile',
    'medicines',
  ];

  static const Map<String, String> _tagDisplayNames = <String, String>{
    'liquids': 'Liquids',
    'perishable_food': 'Perishable food',
    'electronics': 'Electronics',
    'fragile': 'Fragile',
    'medicines': 'Medicines',
  };

  @override
  void dispose() {
    _fromAreaController.dispose();
    _toAreaController.dispose();
    _capacityController.dispose();
    _noteController.dispose();
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

  void _incrementCapacity() {
    final double cur = double.tryParse(_capacityController.text.trim()) ?? 5.0;
    if (cur < 50.0) {
      setState(() {
        _capacityController.text = (cur + 0.5).toStringAsFixed(1);
      });
    }
  }

  void _decrementCapacity() {
    final double cur = double.tryParse(_capacityController.text.trim()) ?? 5.0;
    if (cur > 0.5) {
      setState(() {
        _capacityController.text = (cur - 0.5).toStringAsFixed(1);
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
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
      setState(() => _departureDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final double capacity =
        double.tryParse(_capacityController.text.trim()) ?? 0.0;
    final DateTime now = DateTime.now();

    final currentUser = ref.read(currentUserProvider);
    final String travellerId = currentUser?.id ?? '';
    final String travellerName = currentUser != null && currentUser.name.isNotEmpty
        ? currentUser.name
        : (currentUser != null && currentUser.email.isNotEmpty
            ? currentUser.email.split('@').first
            : 'User');

    final Trip trip = Trip(
      id: 'trip_${now.millisecondsSinceEpoch}',
      travellerId: travellerId,
      travellerName: travellerName,
      fromDistrict: _fromDistrict!,
      fromArea: _fromAreaController.text.trim(),
      toDistrict: _toDistrict!,
      toArea: _toAreaController.text.trim(),
      departureDate: _departureDate,
      capacityKg: capacity,
      noCarryTags: _noCarryTags.toList(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      status: TripStatus.open,
      createdAt: now,
    );

    final bool success = await ref
        .read(postTripControllerProvider.notifier)
        .submitTrip(trip);

    if (mounted && success) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.tripCreatedSuccess),
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
    final state = ref.watch(postTripControllerProvider);
    final DateFormat departureDateFormat = DateFormat('EEE, d MMM');

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: <Widget>[
              // Top Bar: Title & Subtitle + Close 'X' Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          l10n.postTripTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCharcoal,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.postTripSubtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.ticketMutedText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.darkCharcoal,
                      size: 24,
                    ),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

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

              // Two columns: DEPARTURE and CAPACITY
              Row(
                children: <Widget>[
                  // Departure Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'DEPARTURE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ticketMutedText,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
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
                                    departureDateFormat.format(_departureDate),
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
                  const SizedBox(width: 14),

                  // Capacity Stepper Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'CAPACITY',
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
                                onTap: _decrementCapacity,
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
                                  key: const Key('capacityField'),
                                  controller: _capacityController,
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
                                      return 'Enter capacity in kg';
                                    }
                                    final double? parsed =
                                        double.tryParse(val.trim());
                                    if (parsed == null || parsed <= 0) {
                                      return 'Must be greater than 0 kg';
                                    }
                                    if (parsed > 50) {
                                      return 'Cannot exceed 50 kg';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              InkWell(
                                onTap: _incrementCapacity,
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
                ],
              ),
              const SizedBox(height: 22),

              // "Won't carry" Section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Won't carry",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  Text(
                    'Tap to exclude',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ticketMutedText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tags Wrap (Red/pink pill when excluded, neutral beige when carrying)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonTags.map((String tag) {
                  final bool isExcluded = _noCarryTags.contains(tag);
                  final String displayName = _tagDisplayNames[tag] ?? tag;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isExcluded) {
                          _noCarryTags.remove(tag);
                        } else {
                          _noCarryTags.add(tag);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: EdgeInsets.symmetric(
                        horizontal: isExcluded ? 12 : 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: isExcluded
                            ? const Color(0xFFFFEAEA)
                            : AppColors.pillInactive,
                        borderRadius: BorderRadius.circular(20),
                        border: isExcluded
                            ? Border.all(
                                color: const Color(0xFFFFCDD2),
                                width: 1.2,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (isExcluded) ...<Widget>[
                            const Icon(
                              Icons.block,
                              size: 14,
                              color: Color(0xFFD32F2F),
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isExcluded
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isExcluded
                                  ? const Color(0xFFD32F2F)
                                  : AppColors.darkCharcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // Travel Notes Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'TRAVEL NOTES · optional',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ticketMutedText,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('noteField'),
                      controller: _noteController,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkCharcoal,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Train, bus, timing...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.ticketMutedText,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        filled: false,
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error display
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

              // Submit Button: Pill Post trip button
              ElevatedButton(
                key: const Key('submitTripButton'),
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
                        'Post trip',
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
}
