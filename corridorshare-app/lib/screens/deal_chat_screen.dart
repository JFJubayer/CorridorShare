import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/chat/meetup_pin.dart';
import '../core/money/money.dart';
import '../core/theme/app_colors.dart';
import '../models/deal_model.dart';
import '../models/package_model.dart';
import '../providers/user_provider.dart';

class DealChatScreen extends StatefulWidget {
  const DealChatScreen({
    super.key,
    required this.package,
    this.tripId,
    this.dealId,
    this.agreedReward,
  });

  final PackageModel package;
  final String? tripId;
  final String? dealId;
  final double? agreedReward;

  @override
  State<DealChatScreen> createState() => _DealChatScreenState();
}

class _DealChatScreenState extends State<DealChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _dealId;
  Object? _loadError;
  bool _isLoading = true;
  bool _initializationStarted = false;
  bool _sharingPin = false;

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
      if (widget.dealId != null) {
        final existingId = widget.dealId!;
        final known = provider.deals.where((d) => d.id == existingId);
        if (known.isEmpty) {
          throw StateError('Deal $existingId is not available in your inbox yet.');
        }
        await provider.dealsController.loadMessages(existingId);
        if (!mounted) return;
        setState(() {
          _dealId = existingId;
          _isLoading = false;
        });
        return;
      }

      final tripId = widget.tripId ?? _fallbackTripId(provider);
      if (tripId == null) {
        throw StateError(
          'Choose a trip on Matching before opening a deal for this package.',
        );
      }
      final Money? override = widget.agreedReward == null
          ? null
          : Money.fromBdt(widget.agreedReward!);
      final deal = await provider.dealsController.getOrCreateForPackage(
        package: widget.package,
        travelerId: provider.userId,
        tripId: tripId,
        agreedReward: override,
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

  String? _fallbackTripId(UserProvider provider) {
    // Prefer an existing deal for this package that the user already belongs to.
    for (final deal in provider.deals) {
      if (deal.packageId == widget.package.id &&
          (deal.travelerId == provider.userId || deal.senderId == provider.userId)) {
        return deal.tripId;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = (overrideText ?? _messageController.text).trim();
    if (text.isEmpty || _dealId == null) return;
    final provider = context.read<UserProvider>();
    try {
      await provider.dealsController.sendMessage(
        dealId: _dealId!,
        senderId: provider.userId,
        senderName: 'You',
        text: text,
      );
      if (mounted && overrideText == null) _messageController.clear();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _shareMeetupPin() async {
    if (_dealId == null || _sharingPin) return;
    setState(() => _sharingPin = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw StateError('Turn on location services to share a meetup pin.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Location permission is required only when sharing a meetup pin.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final lat = double.parse(position.latitude.toStringAsFixed(5));
      final lng = double.parse(position.longitude.toStringAsFixed(5));
      final encoded = MeetupPin.format(
        lat: lat,
        lng: lng,
        label: 'Meetup',
      );
      await _sendMessage(encoded);
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _sharingPin = false);
    }
  }

  Future<void> _openMeetupMaps(MeetupPin pin) async {
    final uri = Uri.parse(pin.mapsUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open maps for ${pin.lat}, ${pin.lng}')),
      );
    }
  }

  Future<void> _lockEscrow(DealModel deal) async {
    String? inspectionPhotoUrl;
    final provider = context.read<UserProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Lock escrow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'This holds ৳${deal.agreedPrice.asBdt.toStringAsFixed(0)} from the sender wallet in CorridorShare escrow. '
          'Funds stay locked until the recipient OTP is verified at delivery (or refunded). '
          'An open-box inspection photo is required in live mode.',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('CANCEL', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brand),
            child: const Text('LOCK FUNDS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    if (provider.dataMode.name == 'supabase') {
      inspectionPhotoUrl = await _requestInspectionPhotoUrl(deal.id);
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
              ? '৳${deal.agreedPrice.asBdt.toStringAsFixed(0)} locked in escrow until OTP release or refund.'
              : 'Insufficient available wallet balance or deal is no longer negotiable.'),
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

  Future<String?> _requestInspectionPhotoUrl(String dealId) async {
    final provider = context.read<UserProvider>();
    if (provider.dataMode.name != 'supabase') {
      return 'demo://inspection-photo';
    }
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.orangeAccent),
              title: const Text('Take inspection photo', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.orangeAccent),
              title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final name = 'inspection-${DateTime.now().millisecondsSinceEpoch}.jpg';
    return provider.uploadInspectionPhoto(dealId: dealId, bytes: bytes, fileName: name);
  }

  Future<void> _requestRefund(DealModel deal) async {
    try {
      await context.read<UserProvider>().dealsController.requestRefund(deal.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escrow refund requested. Held funds return to the sender when the server confirms.'),
          backgroundColor: AppColors.success,
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
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
            'Release escrow with recipient OTP',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ask the recipient for the six-digit delivery OTP issued after open-box inspection. '
                'CorridorShare verifies the code on the server and then releases escrow to the traveler. '
                'The app never stores or invents this OTP.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '••••••',
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
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Delivery OTP issued', style: TextStyle(color: Colors.white)),
          content: Text(
            'Give this one-time code to the traveler only after you receive and inspect the package. '
            'It authorizes escrow release on the server:\n\n$otp',
            style: const TextStyle(color: Colors.white70),
          ),
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


  Widget _statusChip(String label, {required bool active, required bool done}) {
    final color = done
        ? const Color(0xFF68DBA9)
        : (active ? AppColors.brand : Colors.white24);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active || done ? 0.18 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDealStatusStrip(DealModel deal) {
    final stages = <(DealStatus, String)>[
      (DealStatus.negotiating, 'Negotiate'),
      (DealStatus.escrowLocked, 'Locked'),
      (DealStatus.inTransit, 'In transit'),
      (DealStatus.completed, 'Done'),
    ];
    final currentIndex = switch (deal.status) {
      DealStatus.negotiating => 0,
      DealStatus.escrowLocked => 1,
      DealStatus.inTransit => 2,
      DealStatus.completed => 3,
      DealStatus.cancelled => -1,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      color: AppColors.surfaceDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deal.status == DealStatus.cancelled
                ? 'Deal cancelled / refunded'
                : 'Deal status',
            style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (deal.status == DealStatus.cancelled)
            _statusChip('Cancelled', active: true, done: false)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < stages.length; i++)
                  _statusChip(
                    stages[i].$2,
                    active: i == currentIndex,
                    done: i < currentIndex || deal.status == DealStatus.completed && i == 3,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCheckInChips(DealModel deal, List<ChatMessageModel> messages) {
    final hasMeetup = messages.any((m) => MeetupPin.tryParse(m.text) != null);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      color: AppColors.surfaceDark,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _statusChip(
            deal.openBoxVerified ? 'Open-box verified' : 'Open-box pending',
            active: !deal.openBoxVerified,
            done: deal.openBoxVerified,
          ),
          _statusChip(
            deal.dealLocked ? 'Escrow held' : 'Escrow unlocked',
            active: deal.dealLocked,
            done: deal.status == DealStatus.completed,
          ),
          GestureDetector(
            onTap: hasMeetup || _sharingPin ? null : _shareMeetupPin,
            child: _statusChip(
              hasMeetup ? 'Meetup pin shared' : (_sharingPin ? 'Getting location…' : 'Check-in: share meetup pin'),
              active: !hasMeetup,
              done: hasMeetup,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required ChatMessageModel message,
    required bool isMe,
  }) {
    final pin = MeetupPin.tryParse(message.text);
    if (pin != null) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          decoration: BoxDecoration(
            color: isMe ? AppColors.brand.withValues(alpha: 0.85) : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.place, color: Colors.orangeAccent, size: 18),
                  SizedBox(width: 6),
                  Text('Meetup pin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              Text(pin.label, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(
                '${pin.lat.toStringAsFixed(5)}, ${pin.lng.toStringAsFixed(5)}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _openMeetupMaps(pin),
                icon: const Icon(Icons.map_outlined, size: 16, color: Colors.orangeAccent),
                label: const Text('Open in maps', style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
              ),
              Text(message.timestamp, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9)),
            ],
          ),
        ),
      );
    }

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
            Text('Trip ${deal.tripId} • ${deal.status.label}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDealStatusStrip(deal),
          _buildCheckInChips(deal, messages),
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
                      if (provider.dataMode.name == 'supabase' && deal.senderId == provider.userId)
                        OutlinedButton(
                          onPressed: () => _requestRefund(deal),
                          child: const Text('Refund escrow'),
                        ),
                    ],
                  )
                else
                  Text(deal.status.label, style: const TextStyle(color: AppColors.successLight, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet. Negotiate terms or share a meetup pin.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == provider.userId;
                      return _buildMessageBubble(message: message, isMe: isMe);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.surfaceDark,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Share meetup pin',
                  onPressed: _sharingPin ? null : _shareMeetupPin,
                  icon: _sharingPin
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brand),
                        )
                      : const Icon(Icons.add_location_alt_outlined, color: AppColors.brand),
                ),
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
