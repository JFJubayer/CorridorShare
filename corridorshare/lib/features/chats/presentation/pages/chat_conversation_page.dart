import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/chats/presentation/providers/chat_providers.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:corridorshare/features/offers/presentation/providers/offer_providers.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatConversationPage extends ConsumerStatefulWidget {
  const ChatConversationPage({
    required this.offerId,
    super.key,
  });

  final String offerId;

  @override
  ConsumerState<ChatConversationPage> createState() =>
      _ChatConversationPageState();
}

class _ChatConversationPageState extends ConsumerState<ChatConversationPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String get _currentUserId {
    final user = ref.read(currentUserProvider);
    if (user != null && user.id.isNotEmpty) return user.id;
    final offer = ref.read(offerByIdProvider(widget.offerId)).asData?.value;
    return offer?.travellerId ?? 'traveller-1';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = (overrideText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    if (overrideText == null) {
      _messageController.clear();
    }
    await ref.read(chatSendControllerProvider.notifier).send(
          offerId: widget.offerId,
          text: text,
        );

    // Scroll to bottom smoothly
    if (_scrollController.hasClients) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Future<void> _showCounterDialog(double currentPrice) async {
    final controller = TextEditingController(
      text: currentPrice.toStringAsFixed(0),
    );
    final l10n = AppLocalizations.of(context);

    final newPrice = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.warmIvory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.counterOffer,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.darkCharcoal,
            ),
          ),
          content: TextField(
            key: const Key('counterPriceField'),
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkCharcoal,
            ),
            decoration: InputDecoration(
              labelText: l10n.offerPrice,
              prefixText: '৳ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.commonCancel,
                style: const TextStyle(color: AppColors.ticketMutedText),
              ),
            ),
            FilledButton(
              key: const Key('submitCounterPriceButton'),
              onPressed: () {
                final parsed = double.tryParse(controller.text.trim());
                if (parsed != null && parsed > 0) {
                  Navigator.of(context).pop(parsed);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.darkCharcoal,
              ),
              child: Text(l10n.counterOffer),
            ),
          ],
        );
      },
    );

    if (newPrice != null) {
      await ref.read(offerActionControllerProvider.notifier).counterOffer(
            offerId: widget.offerId,
            newPrice: newPrice,
            counterByUserId: _currentUserId,
          );

      if (_scrollController.hasClients) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 120,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  void _showAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.warmIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.limeAccent,
                    child: Icon(Icons.location_on, color: AppColors.darkCharcoal),
                  ),
                  title: const Text(
                    'Share pickup location',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Send current meeting point to traveller'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _sendMessage('📍 Kamalapur Railway Station, Platform 1');
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.pillInactive,
                    child: Icon(Icons.camera_alt, color: AppColors.darkCharcoal),
                  ),
                  title: const Text(
                    'Parcel photo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Show packaging or dimensions'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _sendMessage('📷 [Parcel Photo Attached: 1.2 kg brown envelope]');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDealDetails(dynamic offer) {
    final isSender = offer.senderId == _currentUserId;
    final roleParam = isSender ? 'sender' : 'carrier';
    context.push('${AppRoutes.deals}?role=$roleParam');
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final offerAsync = ref.watch(offerByIdProvider(widget.offerId));
    final messagesAsync = ref.watch(chatMessagesStreamProvider(widget.offerId));

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkCharcoal),
          onPressed: () => context.pop(),
        ),
        titleSpacing: 0,
        title: offerAsync.when(
          data: (offer) {
            final isSender = offer.senderId == _currentUserId;
            final counterpartName =
                isSender ? offer.travellerName : offer.senderName;
            final initials = _getInitials(counterpartName);
            final role = isSender ? 'Traveller' : 'Sender';
            final rating = offer.travellerRating > 0
                ? offer.travellerRating.toStringAsFixed(1)
                : '4.9';

            return Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.limeAccent,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              counterpartName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkCharcoal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: Color(0xFF7CB342),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.ticketMutedText,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$rating · $role',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ticketMutedText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => Text(l10n.tabChats),
          error: (_, _) => Text(l10n.tabChats),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.darkCharcoal),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Pinned Deal Banner & Action Section
            offerAsync.when(
              data: (offer) => _OfferHeaderBanner(
                offer: offer,
                currentUserId: _currentUserId,
                onOpenDeal: () => _openDealDetails(offer),
                onAccept: () async {
                  await ref
                      .read(offerActionControllerProvider.notifier)
                      .acceptOffer(offer.id);
                  if (mounted) {
                    ref.invalidate(offerByIdProvider(offer.id));
                  }
                },
                onReject: () => ref
                    .read(offerActionControllerProvider.notifier)
                    .rejectOffer(offer.id),
                onCounter: () => _showCounterDialog(offer.price),
                l10n: l10n,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // Handover safety notice
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.shield_outlined,
                    size: 15,
                    color: AppColors.ticketMutedText,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Never share your handover code before pickup.',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ticketMutedText,
                    ),
                  ),
                ],
              ),
            ),

            // Date indicator
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.ticketMutedText,
                ),
              ),
            ),

            // Message Stream List
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.chatEmptyPrompt,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ticketMutedText,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMine = msg.senderId == _currentUserId;
                      return _MessageBubble(message: msg, isMine: isMine);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.darkCharcoal),
                ),
                error: (err, _) => Center(child: Text(err.toString())),
              ),
            ),

            // Quick reply suggestion pills
            _QuickRepliesBar(
              onSelected: (text) => _sendMessage(text),
            ),

            // Bottom Message Input Bar
            offerAsync.maybeWhen(
              data: (offer) {
                final isSender = offer.senderId == _currentUserId;
                final counterpartName =
                    isSender ? offer.travellerName : offer.senderName;
                final firstName = counterpartName.split(' ').first;
                return _MessageInputBar(
                  controller: _messageController,
                  onSend: () => _sendMessage(),
                  onAddAttachment: _showAttachmentSheet,
                  hintText: 'Message $firstName',
                );
              },
              orElse: () => _MessageInputBar(
                controller: _messageController,
                onSend: () => _sendMessage(),
                onAddAttachment: _showAttachmentSheet,
                hintText: l10n.chatInputHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferHeaderBanner extends StatelessWidget {
  const _OfferHeaderBanner({
    required this.offer,
    required this.currentUserId,
    required this.onOpenDeal,
    required this.onAccept,
    required this.onReject,
    required this.onCounter,
    required this.l10n,
  });

  final dynamic offer;
  final String currentUserId;
  final VoidCallback onOpenDeal;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onCounter;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final status = offer.status is OfferStatus
        ? offer.status as OfferStatus
        : OfferStatus.values.firstWhere(
            (e) => e.name == offer.status.toString(),
            orElse: () => OfferStatus.pendingTraveller,
          );

    final isMyTurn = (status == OfferStatus.pendingTraveller &&
            offer.travellerId == currentUserId) ||
        (status == OfferStatus.pendingSender &&
            offer.senderId == currentUserId);

    final isAccepted = status == OfferStatus.accepted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Column(
        children: <Widget>[
          // Pinned Deal Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              offer.parcelTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkCharcoal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Text(
                            ' · ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${offer.fromDistrict} → ${offer.toDistrict}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkCharcoal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          const Text(
                            'Sat 24 Oct · ',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.ticketMutedText,
                            ),
                          ),
                          Text(
                            '৳ ${offer.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                            ),
                          ),
                          const Text(
                            ' in escrow · ',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.ticketMutedText,
                            ),
                          ),
                          Text(
                            isAccepted
                                ? 'Deal Agreed!'
                                : (isMyTurn
                                    ? l10n.offerStatusPendingYou
                                    : l10n.offerStatusPendingOther),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: isAccepted
                                  ? AppColors.darkCharcoal
                                  : (isMyTurn
                                      ? AppColors.warning
                                      : AppColors.ticketMutedText),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onOpenDeal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkCharcoal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Open deal',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Offer Accepted / Escrow status pill
          if (isAccepted) ...<Widget>[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.bannerBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Offer accepted · ৳${offer.price.toStringAsFixed(0)} held in Demo wallet',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
          ],

          // Negotiation actions if pending & user turn
          if (isMyTurn && !status.isTerminal) ...<Widget>[
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('acceptOfferButton'),
                    onPressed: onAccept,
                    icon: const Icon(Icons.check, size: 16),
                    label: Text(l10n.acceptOffer),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.darkCharcoal,
                      foregroundColor: AppColors.limeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('counterOfferButton'),
                    onPressed: onCounter,
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text(l10n.counterOffer),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkCharcoal,
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  key: const Key('rejectOfferButton'),
                  onPressed: onReject,
                  icon: const Icon(Icons.close, color: AppColors.danger),
                  tooltip: l10n.rejectOffer,
                  style: IconButton.styleFrom(
                    side: const BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  final dynamic message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    if (message.senderId == 'system') {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEBE8DC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDDD9CB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: Color(0xFF5A6357),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.text as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333B31),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(message.createdAt as DateTime).toLowerCase();

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        decoration: BoxDecoration(
          color: isMine ? AppColors.darkCharcoal : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMine ? 20 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 20),
          ),
          border: isMine ? null : Border.all(color: AppColors.cardBorder, width: 1.0),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.text,
              style: TextStyle(
                color: isMine ? Colors.white : AppColors.darkCharcoal,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  formattedTime,
                  style: TextStyle(
                    color: isMine ? Colors.white70 : AppColors.ticketMutedText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isMine) ...<Widget>[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: AppColors.limeAccent,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickRepliesBar extends StatelessWidget {
  const _QuickRepliesBar({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const replies = <String>[
      'Thanks!',
      'Share pickup point',
      "I'm here",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: replies.map((text) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(text),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pillInactive,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.onSend,
    required this.onAddAttachment,
    required this.hintText,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAddAttachment;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      color: AppColors.warmIvory,
      child: Row(
        children: <Widget>[
          // Add Attachment button '+'
          GestureDetector(
            onTap: onAddAttachment,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.pillInactive,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 24,
                color: AppColors.darkCharcoal,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Input pill
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0EEE4),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.cardBorder, width: 1.2),
              ),
              child: TextField(
                key: const Key('chatInputField'),
                controller: controller,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.darkCharcoal,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    color: AppColors.ticketMutedText,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            key: const Key('chatSendButton'),
            onTap: onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.limeAccent,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.send_rounded,
                  size: 20,
                  color: AppColors.darkCharcoal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
