import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/deal_model.dart';
import '../models/package_model.dart';
import '../providers/user_provider.dart';

class DealChatScreen extends StatefulWidget {
  const DealChatScreen({super.key, required this.package});

  final PackageModel package;

  @override
  State<DealChatScreen> createState() => _DealChatScreenState();
}

class _DealChatScreenState extends State<DealChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _dealId;
  Object? _loadError;
  bool _isLoading = true;
  bool _initializationStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializationStarted) return;
    _initializationStarted = true;
    _initializeDeal();
  }

  Future<void> _initializeDeal() async {
    final provider = context.read<UserProvider>();
    try {
      String? tripId;
      for (final trip in provider.trips) {
        if (trip.travelerId == provider.userId) {
          tripId = trip.id;
          break;
        }
      }
      if (tripId == null && provider.dataMode.name == 'demo' && provider.trips.isNotEmpty) {
        tripId = provider.trips.first.id;
      }
      if (tripId == null) {
        throw StateError('Post a trip before starting a deal for a package.');
      }
      final deal = await provider.dealsController.getOrCreateForPackage(
        package: widget.package,
        travelerId: provider.userId,
        tripId: tripId,
      );
      await provider.dealsController.loadMessages(deal.id);
      if (!mounted) return;
      setState(() {
        _dealId = deal.id;
        _isLoading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    final provider = context.read<UserProvider>();
    try {
      await provider.dealsController.sendMessage(
        dealId: _dealId!,
        senderId: provider.userId,
        senderName: 'You',
        text: text,
      );
      if (mounted) _messageController.clear();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _lockEscrow(DealModel deal) async {
    String? inspectionPhotoUrl;
    final provider = context.read<UserProvider>();
    if (provider.dataMode.name == 'supabase') {
      inspectionPhotoUrl = await _requestInspectionPhotoUrl();
      if (inspectionPhotoUrl == null) return;
    }
    try {
      final success = await provider.dealsController.lockEscrow(
        deal.id,
        inspectionPhotoUrl: inspectionPhotoUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? '৳${deal.agreedPrice.asBdt.toStringAsFixed(0)} locked safely in CorridorShare Escrow.'
              : 'Insufficient wallet balance or deal is no longer negotiable.'),
          backgroundColor: success ? AppColors.success : Colors.redAccent,
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<String?> _requestInspectionPhotoUrl() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Inspection photo', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Secure inspection photo URL',
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isEmpty) return;
                Navigator.pop(dialogContext, value);
              },
              child: const Text('LOCK ESCROW'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _requestPayoutRelease(DealModel deal) async {
    final otpController = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          title: const Text(
            'Open-Box Delivery OTP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the six-digit recipient verification OTP. Payout authorization is checked by the server.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '••••',
                  hintStyle: TextStyle(color: Colors.white24),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<UserProvider>().dealsController.requestPayoutRelease(
                        dealId: deal.id,
                        otp: otpController.text,
                      );
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                } on Object catch (error) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              child: const Text('VERIFY & RELEASE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } finally {
      otpController.dispose();
    }
  }

  Future<void> _issueDeliveryOtp(DealModel deal) async {
    try {
      final otp = await context.read<UserProvider>().dealsController.issueDeliveryOtp(deal.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delivery OTP issued'),
          content: Text('Give this one-time code to the traveler only after you receive and inspect the package: $otp'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('DONE')),
          ],
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.canvasDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.brand)),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        backgroundColor: AppColors.canvasDark,
        appBar: AppBar(backgroundColor: AppColors.surfaceDark),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to open this deal.\n$_loadError', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
          ),
        ),
      );
    }
    final deal = provider.deals.firstWhere((item) => item.id == _dealId);
    final messages = provider.dealsController.messagesFor(deal.id);

    return Scaffold(
      backgroundColor: AppColors.canvasDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.package.itemDescription, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Deal ID: ${deal.packageId} • ${deal.status.label}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.borderDark,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agreed Surcharge Reward', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('৳ ${deal.agreedPrice.asBdt.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
                if (deal.status == DealStatus.negotiating)
                  ElevatedButton.icon(
                    onPressed: () => _lockEscrow(deal),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
                    icon: const Icon(Icons.lock, color: Colors.white, size: 16),
                    label: const Text('Lock Escrow', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else if (deal.status == DealStatus.escrowLocked)
                  Wrap(
                    spacing: 8,
                    children: [
                      if (provider.dataMode.name == 'supabase' && deal.senderId == provider.userId)
                        OutlinedButton(
                          onPressed: () => _issueDeliveryOtp(deal),
                          child: const Text('Issue OTP'),
                        ),
                      if (provider.dataMode.name == 'supabase' && deal.travelerId == provider.userId)
                        ElevatedButton.icon(
                          onPressed: () => _requestPayoutRelease(deal),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          icon: const Icon(Icons.verified_user, color: Colors.white, size: 16),
                          label: const Text('Release Payout', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  )
                else
                  Text(deal.status.label, style: const TextStyle(color: AppColors.successLight, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.senderId == provider.userId;
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? AppColors.brand : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isMe ? Colors.orangeAccent : Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
                        const SizedBox(height: 4),
                        Text(message.timestamp, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surfaceDark,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Type message or negotiation terms...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.brand),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
