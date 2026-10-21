import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/firebase/firestore_rest_service.dart';
import 'package:corridorshare/features/offers/data/datasources/in_memory_offer_datasource.dart';
import 'package:corridorshare/features/offers/data/datasources/offer_datasource.dart';
import 'package:corridorshare/features/offers/data/models/offer_dto.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirestoreOfferDataSource implements OfferDataSource {
  FirestoreOfferDataSource({
    this.firestore,
    FirestoreRestService? restService,
    bool seed = true,
    String? storageFileName,
  })  : _hasCustomRestService = restService != null,
        _restService = restService ?? FirestoreRestService.instance,
        _storageFileName = storageFileName ?? 'offers.json' {
    if (seed) {
      for (final offer in InMemoryOfferDataSource.seedOffers()) {
        _offers[offer.id] = offer;
      }
    }
    _loadFromLocalStorage();
  }

  final FirebaseFirestore? firestore;
  final bool _hasCustomRestService;
  final FirestoreRestService _restService;
  final String _storageFileName;
  final Map<String, OfferDto> _offers = {};

  bool get _useNativeFirestore =>
      firestore != null || Firebase.apps.isNotEmpty;

  bool get _canSyncRemote =>
      _useNativeFirestore ||
      _hasCustomRestService ||
      _restService.isAuthenticated;

  CollectionReference<Map<String, dynamic>> get _collection =>
      (firestore ?? FirebaseFirestore.instance).collection('offers');

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
        debugPrint('Failed to resolve local offers storage file: $e');
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
          final offer = OfferDto.fromJson(item);
          _offers[offer.id] = offer;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load offers from local storage: $e');
      }
    }
  }

  void _saveToLocalStorage() {
    try {
      final file = _getStorageFile();
      if (file == null) return;
      final jsonList = _offers.values.map((o) => o.toJson()).toList();
      file.writeAsStringSync(json.encode(jsonList));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save offers to local storage: $e');
      }
    }
  }

  @override
  Future<OfferDto> createOffer(OfferDto offer) async {
    final docId = offer.id.isNotEmpty
        ? offer.id
        : 'offer_${DateTime.now().millisecondsSinceEpoch}';
    final isSender = offer.senderId == offer.lastCounterBy;
    final item = offer.copyWith(
      id: docId,
      senderAccepted: isSender,
      travellerAccepted: !isSender,
    );

    _offers[item.id] = item;
    _saveToLocalStorage();

    if (_canSyncRemote) {
      try {
        if (_useNativeFirestore) {
          await _collection.doc(docId).set(item.toJson());
        } else {
          await _restService.setDocument('offers', docId, item.toJson());
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firestore createOffer remote sync note: $e');
        }
      }
    }

    return item;
  }

  @override
  Future<OfferDto> counterOffer({
    required String offerId,
    required double newPrice,
    required String counterByUserId,
  }) async {
    final current = _offers[offerId];
    if (current == null) {
      throw const NotFoundFailure('Offer not found');
    }
    final isSender = counterByUserId == current.senderId;
    final nextStatus = isSender ? 'pendingTraveller' : 'pendingSender';

    final updated = current.copyWith(
      price: newPrice,
      status: nextStatus,
      lastCounterBy: counterByUserId,
      senderAccepted: isSender,
      travellerAccepted: !isSender,
      updatedAt: DateTime.now().toIso8601String(),
    );

    _offers[offerId] = updated;
    _saveToLocalStorage();

    if (_canSyncRemote) {
      try {
        if (_useNativeFirestore) {
          await _collection.doc(offerId).update({
            'price': newPrice,
            'status': nextStatus,
            'lastCounterBy': counterByUserId,
            'senderAccepted': isSender,
            'travellerAccepted': !isSender,
            'updatedAt': updated.updatedAt,
          });
        } else {
          await _restService.updateDocument('offers', offerId, {
            'price': newPrice,
            'status': nextStatus,
            'lastCounterBy': counterByUserId,
            'senderAccepted': isSender,
            'travellerAccepted': !isSender,
            'updatedAt': updated.updatedAt,
          });
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firestore counterOffer remote sync note: $e');
        }
      }
    }

    return updated;
  }

  @override
  Future<OfferDto> acceptOffer(
    String offerId, {
    String? acceptedByUserId,
  }) async {
    final current = _offers[offerId];
    if (current == null) {
      throw const NotFoundFailure('Offer not found');
    }

    bool senderAcc = current.senderAccepted;
    bool travellerAcc = current.travellerAccepted;

    if (acceptedByUserId != null && acceptedByUserId.isNotEmpty) {
      if (acceptedByUserId == current.senderId) {
        senderAcc = true;
      } else if (acceptedByUserId == current.travellerId) {
        travellerAcc = true;
      } else {
        if (!senderAcc) {
          senderAcc = true;
        } else {
          travellerAcc = true;
        }
      }
    } else {
      if (current.status == 'pendingSender') {
        senderAcc = true;
      } else if (current.status == 'pendingTraveller') {
        travellerAcc = true;
      } else {
        senderAcc = true;
        travellerAcc = true;
      }
    }

    final bothAccepted = senderAcc && travellerAcc;
    final nextStatus = bothAccepted
        ? 'accepted'
        : (senderAcc ? 'pendingTraveller' : 'pendingSender');

    final updated = current.copyWith(
      senderAccepted: senderAcc,
      travellerAccepted: travellerAcc,
      status: nextStatus,
      updatedAt: DateTime.now().toIso8601String(),
    );

    _offers[offerId] = updated;
    _saveToLocalStorage();

    if (_canSyncRemote) {
      try {
        if (_useNativeFirestore) {
          await _collection.doc(offerId).update({
            'status': nextStatus,
            'senderAccepted': senderAcc,
            'travellerAccepted': travellerAcc,
            'updatedAt': updated.updatedAt,
          });
        } else {
          await _restService.updateDocument('offers', offerId, {
            'status': nextStatus,
            'senderAccepted': senderAcc,
            'travellerAccepted': travellerAcc,
            'updatedAt': updated.updatedAt,
          });
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firestore acceptOffer remote sync note: $e');
        }
      }
    }

    return updated;
  }

  @override
  Future<OfferDto> rejectOffer(String offerId) async {
    final current = _offers[offerId];
    if (current == null) {
      throw const NotFoundFailure('Offer not found');
    }
    final updated = current.copyWith(
      status: 'rejected',
      updatedAt: DateTime.now().toIso8601String(),
    );

    _offers[offerId] = updated;
    _saveToLocalStorage();

    if (_canSyncRemote) {
      try {
        if (_useNativeFirestore) {
          await _collection.doc(offerId).update({
            'status': 'rejected',
            'updatedAt': updated.updatedAt,
          });
        } else {
          await _restService.updateDocument('offers', offerId, {
            'status': 'rejected',
            'updatedAt': updated.updatedAt,
          });
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firestore rejectOffer remote sync note: $e');
        }
      }
    }

    return updated;
  }

  @override
  Future<OfferDto> getOfferById(String offerId) async {
    if (_offers.containsKey(offerId)) {
      return _offers[offerId]!;
    }

    try {
      if (_useNativeFirestore) {
        final doc = await _collection.doc(offerId).get();
        if (doc.exists && doc.data() != null) {
          final map = Map<String, dynamic>.from(doc.data()!);
          map['id'] = doc.id;
          final dto = OfferDto.fromJson(map);
          _offers[dto.id] = dto;
          _saveToLocalStorage();
          return dto;
        }
      } else {
        final map = await _restService.getDocument('offers', offerId);
        if (map != null) {
          final dto = OfferDto.fromJson(map);
          _offers[dto.id] = dto;
          _saveToLocalStorage();
          return dto;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firestore getOfferById error: $e');
      }
    }

    throw const NotFoundFailure('Offer not found');
  }

  @override
  Future<List<OfferDto>> getOffersForUser(String userId) async {
    if (_canSyncRemote) {
      try {
        if (_useNativeFirestore) {
          final snapshot = await _collection.get();
          for (final doc in snapshot.docs) {
            final map = Map<String, dynamic>.from(doc.data());
            map['id'] = doc.id;
            final dto = OfferDto.fromJson(map);
            _offers[dto.id] = dto;
          }
        } else {
          final docs = await _restService.getDocuments('offers');
          for (final map in docs) {
            final dto = OfferDto.fromJson(map);
            _offers[dto.id] = dto;
          }
        }
        _saveToLocalStorage();
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Firestore getOffersForUser remote sync note: $e');
        }
      }
    }

    return _offers.values.where((o) {
      return o.senderId == userId || o.travellerId == userId;
    }).toList();
  }

  @override
  Future<List<OfferDto>> getOffersForParcel(String parcelId) async {
    if (parcelId == 'parcel-documents' || parcelId == 'parcel-1') {
      final docs = _offers.values
          .where((o) =>
              o.status != 'rejected' &&
              (o.id == 'offer-rafi' ||
                  o.id == 'offer-nila' ||
                  o.id == 'offer-sabbir'))
          .toList();
      if (docs.isNotEmpty) return docs;
    }

    return _offers.values
        .where((o) => o.parcelId == parcelId && o.status != 'rejected')
        .toList();
  }
}
