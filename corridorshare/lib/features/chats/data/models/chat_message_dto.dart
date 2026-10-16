import 'package:corridorshare/features/chats/domain/entities/chat_message.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_dto.freezed.dart';
part 'chat_message_dto.g.dart';

@freezed
abstract class ChatMessageDto with _$ChatMessageDto {
  const factory ChatMessageDto({
    required String id,
    required String offerId,
    required String senderId,
    required String senderName,
    required String text,
    required String createdAt,
  }) = _ChatMessageDto;

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageDtoFromJson(json);

  factory ChatMessageDto.fromDomain(ChatMessage message) => ChatMessageDto(
        id: message.id,
        offerId: message.offerId,
        senderId: message.senderId,
        senderName: message.senderName,
        text: message.text,
        createdAt: message.createdAt.toIso8601String(),
      );
}

extension ChatMessageDtoX on ChatMessageDto {
  ChatMessage toDomain() => ChatMessage(
        id: id,
        offerId: offerId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        createdAt: DateTime.parse(createdAt),
      );
}
