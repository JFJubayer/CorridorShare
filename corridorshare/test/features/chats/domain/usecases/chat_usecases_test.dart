import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/chats/data/datasources/in_memory_chat_datasource.dart';
import 'package:corridorshare/features/chats/data/repositories/chat_repository_impl.dart';
import 'package:corridorshare/features/chats/domain/usecases/get_conversations.dart';
import 'package:corridorshare/features/chats/domain/usecases/get_messages_stream.dart';
import 'package:corridorshare/features/chats/domain/usecases/send_message.dart';
import 'package:corridorshare/features/offers/data/datasources/in_memory_offer_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryOfferDataSource offerDataSource;
  late InMemoryChatDataSource chatDataSource;
  late ChatRepositoryImpl chatRepository;

  late SendMessage sendMessage;
  late GetMessagesStream getMessagesStream;
  late GetConversations getConversations;

  setUp(() {
    offerDataSource = InMemoryOfferDataSource(seed: true);
    chatDataSource = InMemoryChatDataSource(
      offerDataSource: offerDataSource,
      seed: true,
    );
    chatRepository = ChatRepositoryImpl(chatDataSource);

    sendMessage = SendMessage(chatRepository);
    getMessagesStream = GetMessagesStream(chatRepository);
    getConversations = GetConversations(chatRepository);
  });

  group('SendMessage', () {
    test('fails when message is blank or whitespace only', () async {
      final res = await sendMessage(
        offerId: 'offer-1',
        senderId: 'user-1',
        senderName: 'User One',
        text: '   ',
      );

      expect(res, isA<Err>());
    });

    test('successfully sends and stores valid message', () async {
      final res = await sendMessage(
        offerId: 'offer-1',
        senderId: 'current-user-id',
        senderName: 'You (Current User)',
        text: 'Can you deliver by 4 PM?',
      );

      expect(res, isA<Ok>());
      final message = res.getOrThrow();
      expect(message.text, 'Can you deliver by 4 PM?');
      expect(message.senderId, 'current-user-id');
      expect(message.offerId, 'offer-1');
    });
  });

  group('GetMessagesStream', () {
    test('emits initial seed messages and stream updates upon new message', () async {
      final stream = getMessagesStream('offer-1');

      expect(
        stream,
        emitsInOrder([
          // Initial seed messages for offer-1 (3 messages seeded)
          predicate<dynamic>((list) => list.length == 3),
          // After sending a new message
          predicate<dynamic>((list) => list.length == 4),
        ]),
      );

      // Give stream subscription a tick
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await sendMessage(
        offerId: 'offer-1',
        senderId: 'sender-demo-1',
        senderName: 'Tanvir Ahmed',
        text: 'Sure, I will arrive at Agrabad around 3:30 PM.',
      );
    });
  });

  group('GetConversations', () {
    test('returns conversations mapped to user offers with latest messages', () async {
      final res = await getConversations('traveller-1');

      expect(res, isA<Ok>());
      final conversations = res.getOrThrow();
      expect(conversations.length, greaterThanOrEqualTo(2));

      final first = conversations.first;
      expect(first.offerId, isNotEmpty);
      expect(first.counterpartName, isNotEmpty);
      expect(first.lastMessageText, isNotEmpty);
    });
  });
}
