import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_colors.dart';
import '../providers/user_provider.dart';
import '../widgets/ui.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _loading = true;
  Object? _error;
  List<Map<String, dynamic>> _profiles = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<UserProvider>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (provider.dataMode == AppDataMode.demo) {
        setState(() {
          _profiles = const [];
          _loading = false;
          _error =
              'NID review needs live mode. Start the app with DATA_MODE=supabase.';
        });
        return;
      }
      final repository = provider.liveRepository;
      if (repository == null) throw StateError('Live repository unavailable.');
      final profiles = await repository.fetchProfilesForAdmin();
      if (!mounted) return;
      setState(() {
        _profiles = profiles;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _setStatus(String profileId, String status) async {
    final repository = context.read<UserProvider>().liveRepository;
    if (repository == null) return;
    setState(() => _busy = true);
    try {
      await repository.adminSetNidStatus(profileId: profileId, status: status);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('NID status set to $status.')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _profiles.where((p) => p['nid_status'] == 'pending').length;
    final verified =
        _profiles.where((p) => p['nid_status'] == 'verified').length;
    final suspended =
        _profiles.where((p) => p['nid_status'] == 'suspended').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _busy || _loading ? null : _load,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const SkeletonList()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  if (_error != null) ...[
                    InlineNotice('$_error', tone: StatusTone.danger),
                    Gap.lg,
                  ],
                  Row(
                    children: [
                      _Metric('Profiles', _profiles.length),
                      _Metric('Pending', pending),
                      _Metric('Verified', verified),
                      _Metric('Suspended', suspended),
                    ],
                  ),
                  Gap.xl,
                  const SectionHeader('NID review queue'),
                  Gap.sm,
                  if (_profiles.isEmpty)
                    Panel(
                      child: Text(
                        _error == null
                            ? 'No profiles are visible to this session. The admin role is required.'
                            : 'Nothing to review.',
                        style: context.tt.bodyMedium,
                      ),
                    )
                  else
                    Panel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < _profiles.length; i++) ...[
                            if (i > 0) const Divider(indent: 16, endIndent: 16),
                            _profileRow(_profiles[i]),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _creditWallet(String profileId) async {
    final amountController = TextEditingController(text: '500');
    final noteController = TextEditingController(text: 'Staging admin credit');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Credit wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manual staging credit. This is not a payment.'),
            Gap.md,
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration:
                  const InputDecoration(labelText: 'Amount', prefixText: '৳ '),
            ),
            Gap.md,
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Credit'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      amountController.dispose();
      noteController.dispose();
      return;
    }
    final bdt = double.tryParse(amountController.text.trim());
    final note = noteController.text.trim();
    amountController.dispose();
    noteController.dispose();
    if (bdt == null || bdt <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be a positive value.')),
      );
      return;
    }
    if (!mounted) return;
    final repository = context.read<UserProvider>().liveRepository;
    if (repository == null) return;
    setState(() => _busy = true);
    try {
      await repository.adminCreditWallet(
        profileId: profileId,
        amountMinor: (bdt * 100).round(),
        idempotencyKey:
            'admin-credit-$profileId-${DateTime.now().microsecondsSinceEpoch}',
        note: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credited ৳${bdt.toStringAsFixed(0)}.')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _profileRow(Map<String, dynamic> profile) {
    final status = (profile['nid_status'] as String?) ?? 'unverified';
    final tone = switch (status) {
      'verified' => StatusTone.ok,
      'pending' => StatusTone.pending,
      'suspended' => StatusTone.danger,
      _ => StatusTone.neutral,
    };
    final name = (profile['full_name'] as String?)?.trim().isNotEmpty == true
        ? profile['full_name'] as String
        : 'Unnamed member';
    final phone = (profile['phone_number'] as String?) ?? 'No phone';
    final photo = profile['nid_photo_url'] as String?;
    final id = profile['id'] as String;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(
                name,
                image: photo != null && photo.isNotEmpty
                    ? NetworkImage(photo)
                    : null,
              ),
              Gap.md,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: context.tt.titleSmall),
                    Text(phone, style: context.tt.bodySmall),
                  ],
                ),
              ),
              StatusText(_statusLabel(status), tone: tone),
            ],
          ),
          Gap.md,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (status != 'verified')
                FilledButton(
                  onPressed: _busy ? null : () => _setStatus(id, 'verified'),
                  style: _compact,
                  child: const Text('Verify'),
                ),
              if (status != 'pending')
                OutlinedButton(
                  onPressed: _busy ? null : () => _setStatus(id, 'pending'),
                  style: _compact,
                  child: const Text('Mark pending'),
                ),
              OutlinedButton(
                onPressed: _busy ? null : () => _creditWallet(id),
                style: _compact,
                child: const Text('Credit wallet'),
              ),
              if (status != 'suspended')
                TextButton(
                  onPressed: _busy ? null : () => _setStatus(id, 'suspended'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.appColors.danger,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('Suspend'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static final _compact = ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14)),
    textStyle: WidgetStatePropertyAll(
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );

  static String _statusLabel(String status) => switch (status) {
        'verified' => 'Verified',
        'pending' => 'Pending',
        'suspended' => 'Suspended',
        _ => 'Unverified',
      };
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$value', style: context.tt.headlineSmall),
          Text(label, style: context.tt.labelSmall),
        ],
      ),
    );
  }
}
