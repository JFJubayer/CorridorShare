import 'package:corridorshare/features/chats/data/models/chat_message_dto.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_conversation.dart';

abstract class ChatDataSource {
  Future<ChatMessageDto> sendMessage(ChatMessageDto message);

  Stream<List<ChatMessageDto>> getMessagesStream(String offerId);

  Future<List<ChatConversation>> getConversations(String currentUserId);
}
