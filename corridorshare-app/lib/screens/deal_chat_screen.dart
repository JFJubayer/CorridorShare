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
import '../widgets/ui.dart';

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
          throw StateError(
              'Deal $existingId is not available in your inbox yet.');
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
          (deal.travelerId == provider.userId ||
              deal.senderId == provider.userId)) {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
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
        throw StateError(
            'Location permission is required only when sharing a meetup pin.');
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) setState(() => _sharingPin = false);
    }
  }

  Future<void> _openMeetupMaps(MeetupPin pin) async {
    final uri = Uri.parse(pin.mapsUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Could not open maps for ${pin.lat}, ${pin.lng}')),
      );
    }
  }

  Future<void> _lockEscrow(DealModel deal) async {
    String? inspectionPhotoUrl;
    final provider = context.read<UserProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lock escrow'),
        content: Text(
          '৳${deal.agreedPrice.asBdt.toStringAsFixed(0)} moves from the sender wallet into escrow. '
          'It is released when the recipient OTP is verified, or refunded. '
          '${provider.dataMode.name == 'supabase' ? 'An open-box photo is required next.' : ''}',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Lock funds'),
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
              ? '৳${deal.agreedPrice.asBdt.toStringAsFixed(0)} locked in escrow.'
              : 'Not enough available balance, or the deal is no longer negotiable.'),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
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
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Open-box photo', style: ctx.tt.titleLarge),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            Gap.sm,
          ],
        ),
      ),
    );
    if (source == null) return null;
    final file = await picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    final name = 'inspection-${DateTime.now().millisecondsSinceEpoch}.jpg';
    return provider.uploadInspectionPhoto(
        dealId: dealId, bytes: bytes, fileName: name);
  }

  Future<void> _requestRefund(DealModel deal) async {
    try {
      await context.read<UserProvider>().dealsController.requestRefund(deal.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Refund requested. Funds return once the server confirms.')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Future<void> _requestPayoutRelease(DealModel deal) async {
    final otpController = TextEditingController();
    String? error;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('Release escrow'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter the six-digit code the recipient received after inspecting the package.',
                ),
                Gap.md,
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: dialogContext.tt.headlineSmall
                      ?.copyWith(letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '••••••',
                    counterText: '',
                    errorText: error,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await context
                        .read<UserProvider>()
                        .dealsController
                        .requestPayoutRelease(
                          dealId: deal.id,
                          otp: otpController.text,
                        );
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                  } on Object catch (e) {
                    if (!dialogContext.mounted) return;
                    setDialogState(() => error = '$e');
                  }
                },
                child: const Text('Verify and release'),
              ),
            ],
          ),
        ),
      );
    } finally {
      otpController.dispose();
    }
  }

  Future<void> _issueDeliveryOtp(DealModel deal) async {
    try {
      final otp = await context
          .read<UserProvider>()
          .dealsController
          .issueDeliveryOtp(deal.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delivery code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share this with the traveler only after you have received and inspected the package.',
              ),
              Gap.lg,
              Center(
                child: SelectableText(
                  otp,
                  style: dialogContext.tt.headlineMedium
                      ?.copyWith(letterSpacing: 8),
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Done')),
          ],
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Widget _buildDealStatusStrip(
      DealModel deal, List<ChatMessageModel> messages) {
    final stages = <(DealStatus, String)>[
      (DealStatus.negotiating, 'Negotiate'),
      (DealStatus.escrowLocked, 'Locked'),
      (DealStatus.inTransit, 'In transit'),
      (DealStatus.completed, 'Delivered'),
    ];
    final currentIndex = switch (deal.status) {
      DealStatus.negotiating => 0,
      DealStatus.escrowLocked => 1,
      DealStatus.inTransit => 2,
      DealStatus.completed => 3,
      DealStatus.cancelled => -1,
    };
    final hasMeetup = messages.any((m) => MeetupPin.tryParse(m.text) != null);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (deal.status == DealStatus.cancelled)
            const StatusText('Cancelled and refunded', tone: StatusTone.danger)
          else
            Row(
              children: [
                for (var i = 0; i < stages.length; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        color: i <= currentIndex
                            ? context.cs.onSurface
                            : context.cs.outlineVariant,
                      ),
                    ),
                  _StageDot(
                    label: stages[i].$2,
                    done:
                        i < currentIndex || deal.status == DealStatus.completed,
                    active: i == currentIndex,
                  ),
                ],
              ],
            ),
          Gap.md,
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              StatusText(
                deal.openBoxVerified ? 'Open-box verified' : 'Open-box pending',
                tone: deal.openBoxVerified ? StatusTone.ok : StatusTone.neutral,
                icon: Icons.inventory_2_outlined,
              ),
              StatusText(
                deal.dealLocked ? 'Escrow held' : 'Escrow not held',
                tone: deal.dealLocked ? StatusTone.ok : StatusTone.neutral,
                icon: Icons.lock_outline,
              ),
              if (hasMeetup)
                const StatusText('Meetup pin shared',
                    tone: StatusTone.ok, icon: Icons.place_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required ChatMessageModel message,
    required bool isMe,
  }) {
    final cs = context.cs;
    final bg = isMe ? cs.inverseSurface : cs.surfaceContainerLow;
    final fg = isMe ? cs.onInverseSurface : cs.onSurface;
    final fgMuted = fg.withValues(alpha: 0.6);
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(12),
      topRight: const Radius.circular(12),
      bottomLeft: Radius.circular(isMe ? 12 : 2),
      bottomRight: Radius.circular(isMe ? 2 : 12),
    );
    final pin = MeetupPin.tryParse(message.text);

    Widget body;
    if (pin != null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.place_outlined, color: fg, size: 16),
              const SizedBox(width: 6),
              Text(pin.label,
                  style: context.tt.titleSmall?.copyWith(color: fg)),
            ],
          ),
          Gap.xs,
          Text(
            '${pin.lat.toStringAsFixed(5)}, ${pin.lng.toStringAsFixed(5)}',
            style: context.tt.bodySmall?.copyWith(color: fgMuted),
          ),
          Gap.sm,
          TextButton.icon(
            onPressed: () => _openMeetupMaps(pin),
            style: TextButton.styleFrom(
              foregroundColor: fg,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            icon: const Icon(Icons.map_outlined, size: 16),
            label: const Text('Open in maps'),
          ),
        ],
      );
    } else {
      body =
          Text(message.text, style: context.tt.bodyLarge?.copyWith(color: fg));
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(alignment: Alignment.centerLeft, child: body),
            Gap.xs,
            Text(message.timestamp,
                style: context.tt.labelSmall
                    ?.copyWith(color: fgMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const SkeletonList(rows: 3),
      );
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not open this deal',
          message: '$_loadError',
          actionLabel: 'Go back',
          onAction: () => Navigator.of(context).maybePop(),
        ),
      );
    }
    final deal = provider.deals.firstWhere((item) => item.id == _dealId);
    final messages = provider.dealsController.messagesFor(deal.id);
    final isLive = provider.dataMode.name == 'supabase';
    final isSender = deal.senderId == provider.userId;
    final isTraveler = deal.travelerId == provider.userId;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.package.itemDescription,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(deal.routeInfo, style: context.tt.bodySmall),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDealStatusStrip(deal, messages),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Agreed price', style: context.tt.labelMedium),
                      Text('৳ ${deal.agreedPrice.asBdt.toStringAsFixed(0)}',
                          style: context.tt.headlineSmall),
                    ],
                  ),
                ),
                if (deal.status == DealStatus.negotiating)
                  FilledButton.icon(
                    onPressed: () => _lockEscrow(deal),
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: const Text('Lock escrow'),
                  )
                else if (deal.status == DealStatus.escrowLocked && isLive)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.end,
                    children: [
                      if (isSender)
                        OutlinedButton(
                          onPressed: () => _issueDeliveryOtp(deal),
                          child: const Text('Issue code'),
                        ),
                      if (isSender)
                        TextButton(
                          onPressed: () => _requestRefund(deal),
                          child: const Text('Refund'),
                        ),
                      if (isTraveler)
                        FilledButton(
                          onPressed: () => _requestPayoutRelease(deal),
                          child: const Text('Release payout'),
                        ),
                    ],
                  )
                else
                  Text(deal.status.label, style: context.tt.titleSmall),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: messages.isEmpty
                ? const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'Start the conversation',
                    message:
                        'Agree on terms, or share a meetup pin for the handover.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == provider.userId;
                      return _buildMessageBubble(message: message, isMe: isMe);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Share meetup pin',
                    onPressed: _sharingPin ? null : _shareMeetupPin,
                    icon: _sharingPin
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_location_alt_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: 'Message',
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Send',
                    icon: const Icon(Icons.arrow_upward),
                    style: IconButton.styleFrom(
                      backgroundColor: context.cs.primary,
                      foregroundColor: context.cs.onPrimary,
                    ),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot(
      {required this.label, required this.done, required this.active});

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final strong = done || active;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? cs.onSurface : Colors.transparent,
            border: Border.all(
              color: strong ? cs.onSurface : cs.outline,
              width: active ? 2 : 1.5,
            ),
          ),
        ),
        Gap.xs,
        Text(
          label,
          style: context.tt.labelSmall?.copyWith(
            color: strong ? cs.onSurface : cs.onSurfaceVariant,
            fontWeight: active ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
