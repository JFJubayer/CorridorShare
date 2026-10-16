import 'package:corridorshare/core/constants/bangladesh_districts.dart';
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
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  String? _fromDistrict = 'Dhaka';
  String? _toDistrict = 'Chattogram';
  final _fromAreaController = TextEditingController();
  final _toAreaController = TextEditingController();
  final _weightController = TextEditingController(text: '1.0');
  final _priceController = TextEditingController(text: '500');
  final _noteController = TextEditingController();

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

  @override
  void dispose() {
    _titleController.dispose();
    _fromAreaController.dispose();
    _toAreaController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
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

    final weight = double.tryParse(_weightController.text.trim()) ?? 0.0;
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final now = DateTime.now();

    final currentUser = ref.read(currentUserProvider);
    final senderId = currentUser?.id ?? '';
    final senderName = currentUser != null && currentUser.name.isNotEmpty
        ? currentUser.name
        : (currentUser != null && currentUser.email.isNotEmpty
            ? currentUser.email.split('@').first
            : 'User');

    final parcel = Parcel(
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
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: now,
    );

    final success = await ref
        .read(postParcelControllerProvider.notifier)
        .submitParcel(parcel);

    if (mounted && success) {
      final l10n = AppLocalizations.of(context);
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(postParcelControllerProvider);
    final dateFormat = DateFormat('EEE, d MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postParcelTitle),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Text(
                l10n.postParcelSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Title / description
              TextFormField(
                key: const Key('parcelTitleField'),
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.parcelTitleLabel,
                  prefixIcon: const Icon(Icons.inventory_2_outlined),
                  border: const OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter item name' : null,
              ),
              const SizedBox(height: 16),

              // Origin
              DropdownButtonFormField<String>(
                key: const Key('fromDistrictDropdown'),
                isExpanded: true,
                initialValue: _fromDistrict,
                decoration: InputDecoration(
                  labelText: l10n.fromDistrictLabel,
                  prefixIcon: const Icon(Icons.trip_origin),
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
                  prefixIcon: const Icon(Icons.location_on),
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

              // Category Tags
              Text(
                l10n.parcelCategoryLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _suggestedTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Weight and Size in a Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      key: const Key('parcelWeightField'),
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.parcelWeightLabel,
                        prefixIcon: const Icon(Icons.scale),
                        suffixText: 'kg',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter weight';
                        final parsed = double.tryParse(val.trim());
                        if (parsed == null || parsed <= 0) return '> 0 kg';
                        if (parsed > 50) return '≤ 50 kg';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ParcelSize>(
                      key: const Key('parcelSizeDropdown'),
                      isExpanded: true,
                      initialValue: _size,
                      decoration: InputDecoration(
                        labelText: l10n.parcelSizeLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: ParcelSize.values.map((s) {
                        return DropdownMenuItem<ParcelSize>(
                          value: s,
                          child: Text(s.name.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _size = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Offered Price (Reward)
              TextFormField(
                key: const Key('parcelPriceField'),
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.offeredPriceLabel,
                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                  prefixText: '৳ ',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter reward';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Must be > 0 BDT';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Delivery Deadline
              InkWell(
                onTap: _pickDeadline,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.parcelDeadlineLabel,
                    prefixIcon: const Icon(Icons.event),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(dateFormat.format(_deadline)),
                ),
              ),
              const SizedBox(height: 16),

              // Prohibited items declaration (Mandatory Checkbox)
              Material(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _prohibitedDeclared
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: CheckboxListTile(
                  key: const Key('prohibitedDeclarationCheckbox'),
                  value: _prohibitedDeclared,
                  onChanged: (val) =>
                      setState(() => _prohibitedDeclared = val ?? false),
                  title: Text(
                    l10n.prohibitedDeclaration,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 24),

              // Error banner if any
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),

              // Submit button
              FilledButton.icon(
                key: const Key('submitParcelButton'),
                onPressed: state.isLoading ? null : _submit,
                icon: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(l10n.submitParcel),
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
