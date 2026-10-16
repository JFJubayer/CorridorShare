import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_message.dart';
import 'package:corridorshare/features/chats/domain/repositories/chat_repository.dart';

class SendMessage {
  const SendMessage(this._repository);

  final ChatRepository _repository;

  Future<Result<ChatMessage>> call({
    required String offerId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      return const Err<ChatMessage>(
        ValidationFailure('Message cannot be empty'),
      );
    }
    return _repository.sendMessage(
      offerId: offerId,
      senderId: senderId,
      senderName: senderName,
      text: cleanText,
    );
  }
}
