import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_conversation.freezed.dart';

/// Conversation summary item displayed in the Chats tab.
@freezed
abstract class ChatConversation with _$ChatConversation {
  const factory ChatConversation({
    required String offerId,
    required String counterpartId,
    required String counterpartName,
    required String parcelTitle,
    required String fromDistrict,
    required String toDistrict,
    required double price,
    required OfferStatus offerStatus,
    required String lastMessageText,
    required DateTime lastMessageTime,
  }) = _ChatConversation;
}
