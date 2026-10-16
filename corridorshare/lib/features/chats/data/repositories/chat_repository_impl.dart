import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/chats/data/datasources/chat_datasource.dart';
import 'package:corridorshare/features/chats/data/models/chat_message_dto.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_conversation.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_message.dart';
import 'package:corridorshare/features/chats/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl(this._dataSource);

  final ChatDataSource _dataSource;

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String offerId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      final dto = ChatMessageDto(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        offerId: offerId,
        senderId: senderId,
        senderName: senderName,
        text: text,
        createdAt: DateTime.now().toIso8601String(),
      );
      final sent = await _dataSource.sendMessage(dto);
      return Ok<ChatMessage>(sent.toDomain());
    } on Failure catch (f) {
      return Err<ChatMessage>(f);
    } catch (e) {
      return Err<ChatMessage>(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<List<ChatMessage>> getMessagesStream(String offerId) {
    return _dataSource
        .getMessagesStream(offerId)
        .map((dtos) => dtos.map((d) => d.toDomain()).toList());
  }

  @override
  Future<Result<List<ChatConversation>>> getConversations(
    String currentUserId,
  ) async {
    try {
      final conversations = await _dataSource.getConversations(currentUserId);
      return Ok<List<ChatConversation>>(conversations);
    } on Failure catch (f) {
      return Err<List<ChatConversation>>(f);
    } catch (e) {
      return Err<List<ChatConversation>>(UnknownFailure(e.toString()));
    }
  }
}
