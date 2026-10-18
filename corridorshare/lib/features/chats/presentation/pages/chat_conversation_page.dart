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

  String get _currentUserId => ref.read(currentUserProvider)?.id ?? '';

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    await ref.read(chatSendControllerProvider.notifier).send(
          offerId: widget.offerId,
          text: text,
        );

    // Scroll to bottom
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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
          title: Text(l10n.counterOffer),
          content: TextField(
            key: const Key('counterPriceField'),
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.offerPrice,
              prefixText: '৳ ',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              key: const Key('submitCounterPriceButton'),
              onPressed: () {
                final parsed = double.tryParse(controller.text.trim());
                if (parsed != null && parsed > 0) {
                  Navigator.of(context).pop(parsed);
                }
              },
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final offerAsync = ref.watch(offerByIdProvider(widget.offerId));
    final messagesAsync =
        ref.watch(chatMessagesStreamProvider(widget.offerId));

    return Scaffold(
      appBar: AppBar(
        title: offerAsync.when(
          data: (offer) {
            final isSender = offer.senderId == _currentUserId;
            final counterpartName =
                isSender ? offer.travellerName : offer.senderName;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(counterpartName, style: const TextStyle(fontSize: 16)),
                Text(
                  '${offer.fromDistrict} → ${offer.toDistrict}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
          loading: () => Text(l10n.tabChats),
          error: (_, _) => Text(l10n.tabChats),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Offer Negotiation Action Header
            offerAsync.when(
              data: (offer) => _OfferHeaderBanner(
                offer: offer,
                currentUserId: _currentUserId,
                onAccept: () => ref
                    .read(offerActionControllerProvider.notifier)
                    .acceptOffer(offer.id),
                onReject: () => ref
                    .read(offerActionControllerProvider.notifier)
                    .rejectOffer(offer.id),
                onCounter: () => _showCounterDialog(offer.price),
                l10n: l10n,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // Message Stream List
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.chatEmptyPrompt,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMine = msg.senderId == _currentUserId;
                      return _MessageBubble(message: msg, isMine: isMine);
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text(err.toString())),
              ),
            ),

            // Bottom Message Input
            _MessageInputBar(
              controller: _messageController,
              onSend: _sendMessage,
              hintText: l10n.chatInputHint,
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
    required this.onAccept,
    required this.onReject,
    required this.onCounter,
    required this.l10n,
  });

  final dynamic offer;
  final String currentUserId;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onCounter;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = offer.status as OfferStatus;

    final isMyTurn = (status == OfferStatus.pendingTraveller &&
            offer.travellerId == currentUserId) ||
        (status == OfferStatus.pendingSender &&
            offer.senderId == currentUserId);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      offer.parcelTitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      status == OfferStatus.accepted
                          ? l10n.offerStatusAccepted
                          : isMyTurn
                              ? l10n.offerStatusPendingYou
                              : l10n.offerStatusPendingOther,
                      style: TextStyle(
                        fontSize: 12,
                        color: status == OfferStatus.accepted
                            ? Colors.green
                            : (isMyTurn ? Colors.orange : Colors.grey),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '৳ ${offer.price.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (status == OfferStatus.accepted) ...<Widget>[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                key: const Key('trackDeliveryButton'),
                onPressed: () => context.push('/deliveries/delivery-1'),
                icon: const Icon(Icons.local_shipping_outlined, size: 16),
                label: Text(l10n.trackDelivery),
              ),
            ),
          ],
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
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  key: const Key('rejectOfferButton'),
                  onPressed: onReject,
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: l10n.rejectOffer,
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
    final theme = Theme.of(context);
    final timeFormat = DateFormat('h:mm a');

    final bg = isMine
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHigh;
    final fg = isMine
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.text,
              style: TextStyle(color: fg, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              timeFormat.format(message.createdAt as DateTime),
              style: TextStyle(
                color: fg.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.onSend,
    required this.hintText,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              key: const Key('chatInputField'),
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton.filled(
            key: const Key('chatSendButton'),
            icon: const Icon(Icons.send, size: 18),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
