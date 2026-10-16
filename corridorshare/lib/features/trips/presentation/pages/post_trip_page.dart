import 'package:corridorshare/core/constants/bangladesh_districts.dart';
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
  final _formKey = GlobalKey<FormState>();

  String? _fromDistrict = 'Dhaka';
  String? _toDistrict = 'Chattogram';
  final _fromAreaController = TextEditingController();
  final _toAreaController = TextEditingController();
  final _capacityController = TextEditingController(text: '5.0');
  final _noteController = TextEditingController();
  final _customTagController = TextEditingController();

  DateTime _departureDate = DateTime.now().add(const Duration(days: 1));
  final Set<String> _noCarryTags = <String>{'liquids', 'perishable_food'};

  static const List<String> _commonTags = <String>[
    'liquids',
    'perishable_food',
    'electronics',
    'fragile',
    'medicines',
  ];

  @override
  void dispose() {
    _fromAreaController.dispose();
    _toAreaController.dispose();
    _capacityController.dispose();
    _noteController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _departureDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final capacity = double.tryParse(_capacityController.text.trim()) ?? 0.0;
    final now = DateTime.now();

    final currentUser = ref.read(currentUserProvider);
    final travellerId = currentUser?.id ?? '';
    final travellerName = currentUser != null && currentUser.name.isNotEmpty
        ? currentUser.name
        : (currentUser != null && currentUser.email.isNotEmpty
            ? currentUser.email.split('@').first
            : 'User');

    final trip = Trip(
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

    final success = await ref
        .read(postTripControllerProvider.notifier)
        .submitTrip(trip);

    if (mounted && success) {
      final l10n = AppLocalizations.of(context);
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(postTripControllerProvider);
    final dateFormat = DateFormat('EEE, d MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postTripTitle),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Text(
                l10n.postTripSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Origin
              DropdownButtonFormField<String>(
                key: const Key('fromDistrictDropdown'),
                isExpanded: true,
                initialValue: _fromDistrict,
                decoration: InputDecoration(
                  labelText: l10n.fromDistrictLabel,
                  prefixIcon: const Icon(Icons.flight_takeoff),
                  border: const OutlineInputBorder(),
                ),
                items: BangladeshDistricts.all.map((d) {
                  return DropdownMenuItem<String>(
                    value: d,
                    child: Text(d),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _fromDistrict = val),
                validator: (val) =>
                    val == null ? 'Please select origin district' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('fromAreaField'),
                controller: _fromAreaController,
                decoration: InputDecoration(
                  labelText: l10n.fromAreaLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Destination
              DropdownButtonFormField<String>(
                key: const Key('toDistrictDropdown'),
                isExpanded: true,
                initialValue: _toDistrict,
                decoration: InputDecoration(
                  labelText: l10n.toDistrictLabel,
                  prefixIcon: const Icon(Icons.flight_land),
                  border: const OutlineInputBorder(),
                ),
                items: BangladeshDistricts.all.map((d) {
                  return DropdownMenuItem<String>(
                    value: d,
                    child: Text(d),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _toDistrict = val),
                validator: (val) {
                  if (val == null) return 'Please select destination district';
                  if (val == _fromDistrict) {
                    return 'Destination must differ from origin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('toAreaField'),
                controller: _toAreaController,
                decoration: InputDecoration(
                  labelText: l10n.toAreaLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Departure Date
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.departureDateLabel,
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(dateFormat.format(_departureDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Capacity
              TextFormField(
                key: const Key('capacityField'),
                controller: _capacityController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.capacityLabel,
                  prefixIcon: const Icon(Icons.scale),
                  suffixText: 'kg',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Enter capacity in kg';
                  }
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Must be greater than 0 kg';
                  }
                  if (parsed > 50) return 'Cannot exceed 50 kg';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // No-carry tags
              Text(
                l10n.noCarryLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.noCarryHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _commonTags.map((tag) {
                  final isSelected = _noCarryTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _noCarryTags.add(tag);
                        } else {
                          _noCarryTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Trip note
              TextFormField(
                key: const Key('noteField'),
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.tripNoteLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Error display
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),

              // Submit Button
              FilledButton.icon(
                key: const Key('submitTripButton'),
                onPressed: state.isLoading ? null : _submit,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(l10n.submitTrip),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
