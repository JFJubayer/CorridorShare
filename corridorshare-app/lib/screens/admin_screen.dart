import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/config/app_config.dart';
import '../providers/user_provider.dart';

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
          _error = 'Admin NID review uses live profiles via admin_set_nid_status. Switch to DATA_MODE=supabase.';
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
        SnackBar(content: Text('NID status set to $status'), backgroundColor: const Color(0xFF059669)),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = _profiles.where((p) => p['nid_status'] == 'pending').length;
    final verified = _profiles.where((p) => p['nid_status'] == 'verified').length;
    final suspended = _profiles.where((p) => p['nid_status'] == 'suspended').length;

    return Scaffold(
      backgroundColor: const Color(0xFF051424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Safety & Verification Console', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
            onPressed: _busy ? null : _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Text('$_error', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  const Text('Live NID queue (no fake metrics)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _metric('Profiles', '${_profiles.length}', Icons.people, Colors.lightBlueAccent)),
                      const SizedBox(width: 10),
                      Expanded(child: _metric('Pending', '$pending', Icons.hourglass_top, Colors.amberAccent)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _metric('Verified', '$verified', Icons.verified_user, const Color(0xFF059669))),
                      const SizedBox(width: 10),
                      Expanded(child: _metric('Suspended', '$suspended', Icons.gpp_bad, Colors.redAccent)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('National NID review', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (_profiles.isEmpty)
                    const Text('No profiles visible for this session. Admin role is required by RLS.', style: TextStyle(color: Colors.grey))
                  else
                    ..._profiles.map(_profileCard),
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
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('admin_credit_wallet', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Manual staging funding only — not a payment provider.',
              style: TextStyle(color: Colors.amberAccent, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Amount (BDT)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Note',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
            child: const Text('CREDIT', style: TextStyle(color: Colors.white)),
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
        const SnackBar(content: Text('Amount must be a positive BDT value.'), backgroundColor: Colors.redAccent),
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
        idempotencyKey: 'admin-credit-$profileId-${DateTime.now().microsecondsSinceEpoch}',
        note: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credited ৳${bdt.toStringAsFixed(0)} via admin_credit_wallet'), backgroundColor: const Color(0xFF059669)),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _metric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _profileCard(Map<String, dynamic> profile) {
    final status = (profile['nid_status'] as String?) ?? 'unverified';
    final statusColor = switch (status) {
      'verified' => const Color(0xFF059669),
      'pending' => Colors.amber,
      'suspended' => Colors.redAccent,
      _ => Colors.grey,
    };
    final name = (profile['full_name'] as String?)?.trim().isNotEmpty == true
        ? profile['full_name'] as String
        : 'Unnamed member';
    final phone = (profile['phone_number'] as String?) ?? 'No phone';
    final photo = profile['nid_photo_url'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                backgroundImage: photo != null && photo.isNotEmpty ? NetworkImage(photo) : null,
                child: photo == null || photo.isEmpty ? Icon(Icons.person, color: statusColor, size: 18) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('$phone • ${profile['id']}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _busy ? null : () => _setStatus(profile['id'] as String, 'pending'),
                child: const Text('Mark pending'),
              ),
              ElevatedButton(
                onPressed: _busy ? null : () => _setStatus(profile['id'] as String, 'verified'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                child: const Text('Verify', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: _busy ? null : () => _setStatus(profile['id'] as String, 'suspended'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text('Suspend', style: TextStyle(color: Colors.white)),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _creditWallet(profile['id'] as String),
                icon: const Icon(Icons.account_balance_wallet, size: 14),
                label: const Text('Credit wallet'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
