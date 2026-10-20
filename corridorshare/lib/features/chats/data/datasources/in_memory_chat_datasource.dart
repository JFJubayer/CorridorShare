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
            : (seed ? seedMessages() : <ChatMessageDto>[]) {
    _broadcastController = StreamController<List<ChatMessageDto>>.broadcast();
  }

  final OfferDataSource _offerDataSource;
  final List<ChatMessageDto> _messages;
  late final StreamController<List<ChatMessageDto>> _broadcastController;

  static List<ChatMessageDto> seedMessages() {
    final now = DateTime.now();
    return <ChatMessageDto>[
      // Offer 1 (preserved for tests)
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

      // Rafi Mahmud conversation (exact match to screenshot)
      ChatMessageDto(
        id: 'msg-rafi-1',
        offerId: 'offer-rafi',
        senderId: 'traveller-rafi',
        senderName: 'Rafi Mahmud',
        text: "Hi Tania! I'm leaving Dhaka on Saturday morning.",
        createdAt: now.subtract(const Duration(minutes: 50)).toIso8601String(),
      ),
      ChatMessageDto(
        id: 'msg-rafi-2',
        offerId: 'offer-rafi',
        senderId: 'sender-1',
        senderName: 'Tania',
        text: 'Great. Can we meet at Kamalapur station?',
        createdAt: now.subtract(const Duration(minutes: 45)).toIso8601String(),
      ),
      ChatMessageDto(
        id: 'msg-rafi-3',
        offerId: 'offer-rafi',
        senderId: 'traveller-rafi',
        senderName: 'Rafi Mahmud',
        text: 'Yes. What does the parcel look like?',
        createdAt: now.subtract(const Duration(minutes: 30)).toIso8601String(),
      ),
      ChatMessageDto(
        id: 'msg-rafi-4',
        offerId: 'offer-rafi',
        senderId: 'sender-1',
        senderName: 'Tania',
        text: 'A small brown envelope, 1.2 kg.',
        createdAt: now.subtract(const Duration(minutes: 20)).toIso8601String(),
      ),
      ChatMessageDto(
        id: 'msg-rafi-5',
        offerId: 'offer-rafi',
        senderId: 'traveller-rafi',
        senderName: 'Rafi Mahmud',
        text: "Okay, I'll be at Kamalapur at 8:30.",
        createdAt: now.subtract(const Duration(minutes: 5)).toIso8601String(),
      ),

      // Nila Akter
      ChatMessageDto(
        id: 'msg-nila-1',
        offerId: 'offer-nila',
        senderId: 'traveller-nila',
        senderName: 'Nila Akter',
        text: 'Could you do ৳550 instead?',
        createdAt: now.subtract(const Duration(minutes: 40)).toIso8601String(),
      ),

      // Sabbir Hasan
      ChatMessageDto(
        id: 'msg-sabbir-1',
        offerId: 'offer-sabbir',
        senderId: 'sender-1',
        senderName: 'Tania',
        text: "You: I've reported the problem.",
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
      ),

      // Imran Khan
      ChatMessageDto(
        id: 'msg-imran-1',
        offerId: 'offer-imran',
        senderId: 'traveller-imran',
        senderName: 'Imran Khan',
        text: 'Delivered. Thank you!',
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
      ),

      // CorridorShare Support
      ChatMessageDto(
        id: 'msg-support-1',
        offerId: 'offer-support',
        senderId: 'corridorshare-support',
        senderName: 'CorridorShare',
        text: 'Your Demo wallet is ready.',
        createdAt: now.subtract(const Duration(days: 8)).toIso8601String(),
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

      int unread = 0;
      bool isVerified = true;
      String? customTag;
      String? customTagType;

      if (offer.id == 'offer-rafi') {
        unread = 2;
        isVerified = true;
        customTag = 'Agreed';
        customTagType = 'agreed';
      } else if (offer.id == 'offer-nila') {
        unread = 1;
        isVerified = true;
        customTag = 'Counter-offer';
        customTagType = 'counter';
      } else if (offer.id == 'offer-sabbir') {
        unread = 0;
        isVerified = false;
        customTag = 'Disputed';
        customTagType = 'disputed';
      } else if (offer.id == 'offer-imran') {
        unread = 0;
        isVerified = true;
        customTag = 'Delivered';
        customTagType = 'delivered';
      } else if (offer.id == 'offer-support') {
        unread = 0;
        isVerified = false;
        customTag = 'Help';
        customTagType = 'help';
      } else {
        if (offer.status == 'accepted') {
          customTag = 'Agreed';
          customTagType = 'agreed';
        } else {
          customTag = 'Pending';
          customTagType = 'pending';
        }
      }

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
          unreadCount: unread,
          isVerified: isVerified,
          customTag: customTag,
          customTagType: customTagType,
        ),
      );
    }

    conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return conversations;
  }
}
