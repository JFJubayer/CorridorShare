import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_conversation.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_message.dart';
import 'package:corridorshare/features/chats/domain/usecases/get_conversations.dart';
import 'package:corridorshare/features/chats/domain/usecases/get_messages_stream.dart';
import 'package:corridorshare/features/chats/domain/usecases/send_message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:corridorshare/core/di/injection.dart'
    show chatDataSourceProvider, chatRepositoryProvider;

final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  return SendMessage(ref.watch(chatRepositoryProvider));
});

final getMessagesStreamUseCaseProvider = Provider<GetMessagesStream>((ref) {
  return GetMessagesStream(ref.watch(chatRepositoryProvider));
});

final getConversationsUseCaseProvider = Provider<GetConversations>((ref) {
  return GetConversations(ref.watch(chatRepositoryProvider));
});

/// Live stream of messages for a given offerId.
final chatMessagesStreamProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, offerId) {
  final useCase = ref.watch(getMessagesStreamUseCaseProvider);
  return useCase(offerId);
});

/// List of conversations for the current user.
/// List of conversations for the current user.
final conversationsProvider =
    FutureProvider<List<ChatConversation>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return const [];
  final useCase = ref.watch(getConversationsUseCaseProvider);
  final result = await useCase(currentUser.id);
  return result.fold(
    (conversations) => conversations,
    (failure) => throw Exception(failure.message),
  );
});

/// Message sender state notifier.
class ChatSendState {
  const ChatSendState({
    this.isSending = false,
    this.errorMessage,
  });

  final bool isSending;
  final String? errorMessage;
}

class ChatSendController extends StateNotifier<ChatSendState> {
  ChatSendController(this._sendMessage, this._ref)
      : super(const ChatSendState());

  final SendMessage _sendMessage;
  final Ref _ref;

  Future<bool> send({
    required String offerId,
    required String text,
  }) async {
    state = const ChatSendState(isSending: true);
    final currentUser = _ref.read(currentUserProvider);
    final senderId = currentUser?.id ?? '';
    final senderName = currentUser != null && currentUser.name.isNotEmpty
        ? currentUser.name
        : (currentUser != null && currentUser.email.isNotEmpty
            ? currentUser.email.split('@').first
            : 'User');

    final result = await _sendMessage(
      offerId: offerId,
      senderId: senderId,
      senderName: senderName,
      text: text,
    );

    return result.fold(
      (sent) {
        if (mounted) {
          state = const ChatSendState(isSending: false);
        }
        _ref.invalidate(conversationsProvider);
        return true;
      },
      (failure) {
        if (mounted) {
          state = ChatSendState(
            isSending: false,
            errorMessage: failure.message,
          );
        }
        return false;
      },
    );
  }
}

final chatSendControllerProvider =
    StateNotifierProvider.autoDispose<ChatSendController, ChatSendState>((ref) {
  return ChatSendController(ref.watch(sendMessageUseCaseProvider), ref);
});
