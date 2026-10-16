import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_conversation.dart';
import 'package:corridorshare/features/chats/domain/repositories/chat_repository.dart';

class GetConversations {
  const GetConversations(this._repository);

  final ChatRepository _repository;

  Future<Result<List<ChatConversation>>> call(String currentUserId) {
    return _repository.getConversations(currentUserId);
  }
}
