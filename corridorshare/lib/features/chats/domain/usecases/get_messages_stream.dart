import 'package:corridorshare/features/chats/domain/entities/chat_message.dart';
import 'package:corridorshare/features/chats/domain/repositories/chat_repository.dart';

class GetMessagesStream {
  const GetMessagesStream(this._repository);

  final ChatRepository _repository;

  Stream<List<ChatMessage>> call(String offerId) {
    return _repository.getMessagesStream(offerId);
  }
}
