import 'dart:io';

import 'package:corridorshare/core/firebase/firestore_rest_service.dart';
import 'package:corridorshare/features/chats/data/datasources/firestore_chat_datasource.dart';
import 'package:corridorshare/features/chats/data/models/chat_message_dto.dart';
import 'package:corridorshare/features/offers/data/datasources/in_memory_offer_datasource.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirestoreRestService extends FirestoreRestService {
  MockFirestoreRestService();

  final Map<String, Map<String, dynamic>> database = {};

  @override
  Future<Map<String, dynamic>> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    final key = '$collection/$docId';
    database[key] = Map<String, dynamic>.from(data);
    return {'id': docId, ...data};
  }

  @override
  Future<List<Map<String, dynamic>>> getDocuments(String collection) async {
    final prefix = '$collection/';
    final results = <Map<String, dynamic>>[];
    for (final entry in database.entries) {
      if (entry.key.startsWith(prefix)) {
        final docId = entry.key.substring(prefix.length);
        results.add({'id': docId, ...entry.value});
      }
    }
    return results;
  }
}

void main() {
  late MockFirestoreRestService fakeRest;
  late InMemoryOfferDataSource offerDs;
  late String testStorageFileName;

  setUp(() {
    fakeRest = MockFirestoreRestService();
    offerDs = InMemoryOfferDataSource(seed: true);
    testStorageFileName = 'test_chat_${DateTime.now().microsecondsSinceEpoch}.json';
  });

  tearDown(() {
    try {
      final home = Platform.environment['HOME'] ?? Directory.current.path;
      final file = File('$home/.corridorshare/$testStorageFileName');
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {}
  });

  test('sendMessage persists to database and local store', () async {
    final chatDs = FirestoreChatDataSource(
      restService: fakeRest,
      offerDataSource: offerDs,
      seed: true,
      storageFileName: testStorageFileName,
    );

    const message = ChatMessageDto(
      id: 'msg-test-101',
      offerId: 'offer-rafi',
      senderId: 'sender-1',
      senderName: 'Tania',
      text: 'Meeting at platform 4.',
      createdAt: '2026-10-20T19:00:00.000Z',
    );

    final sent = await chatDs.sendMessage(message);
    expect(sent.id, equals('msg-test-101'));
    expect(sent.text, equals('Meeting at platform 4.'));

    // Verify written to database
    expect(fakeRest.database.containsKey('conversations/offer-rafi/messages/msg-test-101'), isTrue);
    expect(fakeRest.database['conversations/offer-rafi/messages/msg-test-101']?['text'], equals('Meeting at platform 4.'));
    expect(fakeRest.database.containsKey('conversations/offer-rafi'), isTrue);
    expect(fakeRest.database['conversations/offer-rafi']?['lastMessageText'], equals('Meeting at platform 4.'));
  });

  test('messages survive app restart via persistent storage', () async {
    // 1. Session 1: Send a message
    final chatDs1 = FirestoreChatDataSource(
      restService: fakeRest,
      offerDataSource: offerDs,
      seed: true,
      storageFileName: testStorageFileName,
    );

    await chatDs1.sendMessage(
      const ChatMessageDto(
        id: 'msg-persist-1',
        offerId: 'offer-rafi',
        senderId: 'sender-1',
        senderName: 'Tania',
        text: 'Important parcel note across restart.',
        createdAt: '2026-10-20T19:10:00.000Z',
      ),
    );

    // 2. Session 2 (simulating fresh app restart)
    final chatDs2 = FirestoreChatDataSource(
      restService: fakeRest,
      offerDataSource: offerDs,
      seed: true,
      storageFileName: testStorageFileName,
    );

    final messages = await chatDs2.getMessagesStream('offer-rafi').first;
    expect(messages.any((m) => m.id == 'msg-persist-1' && m.text == 'Important parcel note across restart.'), isTrue);

    // Also verify getConversations displays the persisted message text
    final conversations = await chatDs2.getConversations('sender-1');
    final rafiConvo = conversations.firstWhere((c) => c.offerId == 'offer-rafi');
    expect(rafiConvo.lastMessageText, equals('Important parcel note across restart.'));
  });
}
