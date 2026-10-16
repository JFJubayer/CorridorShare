import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

/// Realtime message tied to an offer / deal.
@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String offerId,
    required String senderId,
    required String senderName,
    required String text,
    required DateTime createdAt,
  }) = _ChatMessage;
}
