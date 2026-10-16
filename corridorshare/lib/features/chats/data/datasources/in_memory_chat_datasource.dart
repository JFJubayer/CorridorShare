import 'dart:async';

import 'package:corridorshare/features/chats/data/datasources/chat_datasource.dart';
import 'package:corridorshare/features/chats/data/models/chat_message_dto.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_conversation.dart';
import 'package:corridorshare/features/offers/data/datasources/offer_datasource.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';

class InMemoryChatDataSource implements ChatDataSource {
  InMemoryChatDataSource({
    required this._offerDataSource,
    List<ChatMessageDto>? initialMessages,
    bool seed = false,
  })  : _messages = initialMessages != null
            ? List<ChatMessageDto>.from(initialMessages)
            : (seed ? _seedMessages() : <ChatMessageDto>[]) {
    _broadcastController = StreamController<List<ChatMessageDto>>.broadcast();
  }

  final OfferDataSource _offerDataSource;
  final List<ChatMessageDto> _messages;
  late final StreamController<List<ChatMessageDto>> _broadcastController;

  static List<ChatMessageDto> _seedMessages() {
    final now = DateTime.now();
    return <ChatMessageDto>[
      ChatMessageDto(
        id: 'msg-1',
        offerId: 'offer-1',
        senderId: 'sender-1',
        senderName: 'Tanvir Ahmed',
        text: 'Hello! I saw you are travelling from Dhaka to Chattogram by train.',
        createdAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      ChatMessageDto(
        id: 'msg-2',
        offerId: 'offer-1',
        senderId: 'traveller-1',
        senderName: 'Rafiqul Islam',
        text: 'Yes, leaving Friday morning at 7:00 AM.',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 45)).toIso8601String(),
      ),
      ChatMessageDto(
        id: 'msg-3',
        offerId: 'offer-1',
        senderId: 'sender-1',
        senderName: 'Tanvir Ahmed',
        text: 'Great, can you carry a small document envelope?',
        createdAt: now.subtract(const Duration(hours: 1, minutes: 30)).toIso8601String(),
      ),
    ];
  }

  @override
  Future<ChatMessageDto> sendMessage(ChatMessageDto message) async {
    _messages.add(message);
    _broadcastController.add(
      _messages.where((m) => m.offerId == message.offerId).toList(),
    );
    return message;
  }

  @override
  Stream<List<ChatMessageDto>> getMessagesStream(String offerId) async* {
    // Emit initial messages
    yield _messages.where((m) => m.offerId == offerId).toList();
    // Yield subsequent updates
    yield* _broadcastController.stream
        .map((list) => _messages.where((m) => m.offerId == offerId).toList());
  }

  @override
  Future<List<ChatConversation>> getConversations(String currentUserId) async {
    final userOffers = await _offerDataSource.getOffersForUser(currentUserId);
    final conversations = <ChatConversation>[];

    for (final offer in userOffers) {
      final isSender = offer.senderId == currentUserId;
      final counterpartId = isSender ? offer.travellerId : offer.senderId;
      final counterpartName = isSender ? offer.travellerName : offer.senderName;

      final offerMsgs = _messages
          .where((m) => m.offerId == offer.id)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final lastText = offerMsgs.isNotEmpty
          ? offerMsgs.first.text
          : 'Offer initiated for ৳${offer.price.toStringAsFixed(0)}';
      final lastTime = offerMsgs.isNotEmpty
          ? DateTime.parse(offerMsgs.first.createdAt)
          : DateTime.parse(offer.updatedAt);

      conversations.add(
        ChatConversation(
          offerId: offer.id,
          counterpartId: counterpartId,
          counterpartName: counterpartName,
          parcelTitle: offer.parcelTitle,
          fromDistrict: offer.fromDistrict,
          toDistrict: offer.toDistrict,
          price: offer.price,
          offerStatus: OfferStatus.values.firstWhere(
            (e) => e.name == offer.status,
            orElse: () => OfferStatus.pendingTraveller,
          ),
          lastMessageText: lastText,
          lastMessageTime: lastTime,
        ),
      );
    }

    conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return conversations;
  }
}
