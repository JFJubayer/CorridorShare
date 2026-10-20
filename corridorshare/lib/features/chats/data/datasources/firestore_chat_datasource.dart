import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/firebase/firestore_rest_service.dart';
import 'package:corridorshare/features/chats/data/datasources/chat_datasource.dart';
import 'package:corridorshare/features/chats/data/datasources/in_memory_chat_datasource.dart';
import 'package:corridorshare/features/chats/data/models/chat_message_dto.dart';
import 'package:corridorshare/features/chats/domain/entities/chat_conversation.dart';
import 'package:corridorshare/features/offers/data/datasources/offer_datasource.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirestoreChatDataSource implements ChatDataSource {
  FirestoreChatDataSource({
    this.firestore,
    FirestoreRestService? restService,
    required OfferDataSource offerDataSource,
    bool seed = true,
    String? storageFileName,
  })  : _hasCustomRestService = restService != null,
        _restService = restService ?? FirestoreRestService.instance,
        _offerDataSource = offerDataSource,
        _storageFileName = storageFileName ?? 'chat_messages.json' {
    _broadcastController = StreamController<List<ChatMessageDto>>.broadcast();
    if (seed) {
      for (final msg in InMemoryChatDataSource.seedMessages()) {
        _messages[msg.id] = msg;
      }
    }
    _loadFromLocalStorage();
  }

  final FirebaseFirestore? firestore;
  final bool _hasCustomRestService;
  final FirestoreRestService _restService;
  final OfferDataSource _offerDataSource;
  final String _storageFileName;

  final Map<String, ChatMessageDto> _messages = {};
  late final StreamController<List<ChatMessageDto>> _broadcastController;

  bool get _useNativeFirestore =>
      firestore != null || Firebase.apps.isNotEmpty;

  bool get _canSyncRemote =>
      _useNativeFirestore ||
      _hasCustomRestService ||
      _restService.isAuthenticated;

  CollectionReference<Map<String, dynamic>> get _conversationsCollection =>
      (firestore ?? FirebaseFirestore.instance).collection('conversations');

  File? _getStorageFile() {
    if (kIsWeb) return null;
    try {
      String? dirPath;
      if (Platform.isLinux || Platform.isMacOS) {
        final home = Platform.environment['HOME'] ?? Directory.current.path;
        dirPath = '$home/.corridorshare';
      } else if (Platform.isWindows) {
        final appData = Platform.environment['APPDATA'] ?? Directory.current.path;
        dirPath = '$appData/CorridorShare';
      } else if (Platform.isAndroid || Platform.isIOS) {
        dirPath = Directory.systemTemp.path;
      }
      if (dirPath != null) {
        final dir = Directory(dirPath);
        if (!dir.existsSync()) {
          dir.createSync(recursive: true);
        }
        return File('${dir.path}/$_storageFileName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to resolve local chat storage file: $e');
      }
    }
    return null;
  }

  void _loadFromLocalStorage() {
    try {
      final file = _getStorageFile();
      if (file == null || !file.existsSync()) return;
      final content = file.readAsStringSync();
      if (content.trim().isEmpty) return;
      final jsonList = json.decode(content) as List<dynamic>;
      for (final item in jsonList) {
        if (item is Map<String, dynamic>) {
          final msg = ChatMessageDto.fromJson(item);
          _messages[msg.id] = msg;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load chat messages from local storage: $e');
      }
    }
  }

  void _saveToLocalStorage() {
    try {
      final file = _getStorageFile();
      if (file == null) return;
      final jsonList = _messages.values.map((m) => m.toJson()).toList();
      file.writeAsStringSync(json.encode(jsonList));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save chat messages to local storage: $e');
      }
    }
  }

  List<ChatMessageDto> _getOfferMessages(String offerId) {
    final list = _messages.values.where((m) => m.offerId == offerId).toList();
    list.sort((a, b) {
      final da = DateTime.tryParse(a.createdAt) ?? DateTime(1970);
      final db = DateTime.tryParse(b.createdAt) ?? DateTime(1970);
      return da.compareTo(db);
    });
    return list;
  }

  @override
  Future<ChatMessageDto> sendMessage(ChatMessageDto message) async {
    try {
      final docId = message.id.isNotEmpty
          ? message.id
          : 'msg_${DateTime.now().millisecondsSinceEpoch}';
      final item = message.copyWith(id: docId);

      // 1. Immediately store in local memory and disk cache so restarts never lose it
      _messages[item.id] = item;
      _saveToLocalStorage();

      // 2. Broadcast immediately for instant UI reaction
      _broadcastController.add(_getOfferMessages(item.offerId));

      // 3. Persist to Firestore database
      if (_canSyncRemote) {
        if (_useNativeFirestore) {
          await _conversationsCollection
              .doc(item.offerId)
              .collection('messages')
              .doc(docId)
              .set(item.toJson());
          await _conversationsCollection.doc(item.offerId).set({
            'id': item.offerId,
            'lastMessageText': item.text,
            'lastMessageTime': item.createdAt,
            'lastSenderId': item.senderId,
            'lastSenderName': item.senderName,
            'updatedAt': item.createdAt,
          }, SetOptions(merge: true));
        } else {
          await _restService.setDocument(
            'conversations/${item.offerId}/messages',
            docId,
            item.toJson(),
          );
          await _restService.setDocument(
            'conversations',
            item.offerId,
            {
              'id': item.offerId,
              'lastMessageText': item.text,
              'lastMessageTime': item.createdAt,
              'lastSenderId': item.senderId,
              'lastSenderName': item.senderName,
              'updatedAt': item.createdAt,
            },
          );
        }
      }

      return item;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firestore sendMessage remote sync note: $e');
      }
      // Even if network or Firestore remote fails, local message is preserved!
      return message;
    }
  }

  Future<void> _syncMessagesFromFirestore(String offerId) async {
    if (!_canSyncRemote) return;
    try {
      if (_useNativeFirestore) {
        final snapshot = await _conversationsCollection
            .doc(offerId)
            .collection('messages')
            .orderBy('createdAt', descending: false)
            .get();
        bool changed = false;
        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          final dto = ChatMessageDto.fromJson(data);
          if (!_messages.containsKey(dto.id) || _messages[dto.id] != dto) {
            _messages[dto.id] = dto;
            changed = true;
          }
        }
        if (changed) {
          _saveToLocalStorage();
          _broadcastController.add(_getOfferMessages(offerId));
        }
      } else {
        final docs = await _restService
            .getDocuments('conversations/$offerId/messages');
        bool changed = false;
        for (final map in docs) {
          final dto = ChatMessageDto.fromJson(map);
          if (!_messages.containsKey(dto.id) || _messages[dto.id] != dto) {
            _messages[dto.id] = dto;
            changed = true;
          }
        }
        if (changed) {
          _saveToLocalStorage();
          _broadcastController.add(_getOfferMessages(offerId));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firestore chat sync error for $offerId: $e');
      }
    }
  }

  @override
  Stream<List<ChatMessageDto>> getMessagesStream(String offerId) async* {
    // 1. Immediately yield local & seeded messages
    yield _getOfferMessages(offerId);

    // 2. Fetch from Firestore database in background to sync
    unawaited(_syncMessagesFromFirestore(offerId));

    // 3. If native Firestore, listen to real-time snapshots
    if (_useNativeFirestore) {
      final snapStream = _conversationsCollection
          .doc(offerId)
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots();

      yield* snapStream.map((snapshot) {
        for (final doc in snapshot.docs) {
          final data = Map<String, dynamic>.from(doc.data());
          data['id'] = doc.id;
          final dto = ChatMessageDto.fromJson(data);
          _messages[dto.id] = dto;
        }
        _saveToLocalStorage();
        return _getOfferMessages(offerId);
      });
    } else {
      // 4. Yield live updates from local broadcast controller
      yield* _broadcastController.stream
          .map((_) => _getOfferMessages(offerId));
    }
  }

  @override
  Future<List<ChatConversation>> getConversations(String currentUserId) async {
    final userOffers = await _offerDataSource.getOffersForUser(currentUserId);
    final conversations = <ChatConversation>[];

    for (final offer in userOffers) {
      // Background sync from remote database
      unawaited(_syncMessagesFromFirestore(offer.id));

      final isSender = offer.senderId == currentUserId;
      final counterpartId = isSender ? offer.travellerId : offer.senderId;
      final counterpartName = isSender ? offer.travellerName : offer.senderName;

      final offerMsgs = _getOfferMessages(offer.id);

      final lastText = offerMsgs.isNotEmpty
          ? offerMsgs.last.text
          : 'Offer initiated for ৳${offer.price.toStringAsFixed(0)}';
      final lastTime = offerMsgs.isNotEmpty
          ? (DateTime.tryParse(offerMsgs.last.createdAt) ?? DateTime.now())
          : (DateTime.tryParse(offer.updatedAt) ?? DateTime.now());

      int unread = 0;
      bool isVerified = true;
      String? customTag;
      String? customTagType;

      if (offer.id == 'offer-rafi') {
        unread = 2;
        isVerified = true;
        customTag = 'Agreed';
        customTagType = 'agreed';
      } else if (offer.id == 'offer-nila') {
        unread = 1;
        isVerified = true;
        customTag = 'Counter-offer';
        customTagType = 'counter';
      } else if (offer.id == 'offer-sabbir') {
        unread = 0;
        isVerified = false;
        customTag = 'Disputed';
        customTagType = 'disputed';
      } else if (offer.id == 'offer-imran') {
        unread = 0;
        isVerified = true;
        customTag = 'Delivered';
        customTagType = 'delivered';
      } else if (offer.id == 'offer-support') {
        unread = 0;
        isVerified = false;
        customTag = 'Help';
        customTagType = 'help';
      } else {
        if (offer.status == 'accepted') {
          customTag = 'Agreed';
          customTagType = 'agreed';
        } else {
          customTag = 'Pending';
          customTagType = 'pending';
        }
      }

      conversations.add(
        ChatConversation(
          offerId: offer.id,
          counterpartId: counterpartId,
          counterpartName: counterpartName,
          parcelTitle: offer.parcelTitle,
          fromDistrict: offer.fromDistrict,
          toDistrict: offer.toDistrict,
          price: offer.price,
          offerStatus: OfferStatus.values.firstWhere(
            (e) => e.name == offer.status,
            orElse: () => OfferStatus.pendingTraveller,
          ),
          lastMessageText: lastText,
          lastMessageTime: lastTime,
          unreadCount: unread,
          isVerified: isVerified,
          customTag: customTag,
          customTagType: customTagType,
        ),
      );
    }

    conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return conversations;
  }
}
