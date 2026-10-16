import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_conversation.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<Result<ChatMessage>> sendMessage({
    required String offerId,
    required String senderId,
    required String senderName,
    required String text,
  });

  Stream<List<ChatMessage>> getMessagesStream(String offerId);

  Future<Result<List<ChatConversation>>> getConversations(String currentUserId);
}
