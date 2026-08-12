import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../core/money/money.dart';
import '../../models/deal_model.dart';
import '../../models/package_model.dart';
import '../../infrastructure/supabase/supabase_backend_repository.dart';
import '../wallet/wallet_controller.dart';
import 'data/deals_repository.dart';

class DealsController extends ChangeNotifier {
  DealsController({
    required AppConfig config,
    required WalletController wallet,
    SupabaseBackendRepository? liveRepository,
    DealsRepository? dealsRepository,
    MessagesRepository? messagesRepository,
  })  : _config = config,
        _wallet = wallet,
        _liveRepository = liveRepository,
        _dealsRepository = dealsRepository ?? FakeDealsRepository(),
        _messagesRepository = messagesRepository ?? FakeMessagesRepository();

  final AppConfig _config;
  final WalletController _wallet;
  final SupabaseBackendRepository? _liveRepository;
  final DealsRepository _dealsRepository;
  final MessagesRepository _messagesRepository;
  List<DealModel> _liveDeals = const [];
  final Map<String, List<ChatMessageModel>> _liveMessages = {};

  List<DealModel> get deals => _config.isDemo
      ? _dealsRepository.all
      : List.unmodifiable(_liveDeals);
  List<ChatMessageModel> messagesFor(String dealId) => _config.isDemo
      ? _messagesRepository.forDeal(dealId)
      : List.unmodifiable(_liveMessages[dealId] ?? const []);

  Future<void> hydrate(SupabaseBackendRepository repository) async {
    _liveDeals = await repository.fetchDeals();
    notifyListeners();
  }

  Future<DealModel> getOrCreateForPackage({
    required PackageModel package,
    required String travelerId,
    required String tripId,
    Money? agreedReward,
  }) async {
    DealModel? existing;
    for (final candidate in deals) {
      if (candidate.packageId == package.id && candidate.tripId == tripId) {
        existing = candidate;
        break;
      }
    }
    if (existing != null) return existing;

    final amount = agreedReward ?? package.reward;
    final deal = DealModel(
      id: 'deal-${package.id}-$tripId',
      tripId: tripId,
      packageId: package.id,
      travelerId: travelerId,
      senderId: package.senderId,
      agreedPrice: amount,
      status: DealStatus.negotiating,
      packageItem: package.itemDescription,
      routeInfo: package.routeInfo,
    );
    if (!_config.isDemo) {
      final repository = _liveRepository;
      if (repository == null) throw StateError('Live Supabase repository is unavailable.');
      final row = await repository.createDeal(
        tripId: tripId,
        packageId: package.id,
        amount: amount,
      );
      final created = DealModel(
        id: row['id'] as String,
        tripId: tripId,
        packageId: package.id,
        travelerId: travelerId,
        senderId: package.senderId,
        agreedPrice: amount,
        status: DealStatusWire.fromWire(row['status'] as String),
        dealLocked: row['deal_locked'] as bool? ?? false,
        openBoxVerified: row['open_box_verified'] as bool? ?? false,
        packageItem: package.itemDescription,
        routeInfo: package.routeInfo,
      );
      _liveDeals = [created, ..._liveDeals];
      notifyListeners();
      return created;
    }

    _dealsRepository.save(deal);
    _messagesRepository.add(ChatMessageModel(
      id: 'message-${package.id}-welcome',
      dealId: deal.id,
      senderId: package.senderId,
      senderName: 'Sender',
      text: 'Hi! Can you carry "${package.itemDescription}" along the corridor?',
      createdAt: DateTime.now().toUtc(),
    ));
    notifyListeners();
    return deal;
  }

  Future<void> loadMessages(String dealId) async {
    if (_config.isDemo) return;
    final repository = _liveRepository;
    if (repository == null) throw StateError('Live Supabase repository is unavailable.');
    _liveMessages[dealId] = await repository.fetchMessages(dealId);
    notifyListeners();
  }

  Future<void> sendMessage({
    required String dealId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      throw ArgumentError.value(text, 'text', 'cannot be empty');
    }
    final message = ChatMessageModel(
      id: 'message-${DateTime.now().microsecondsSinceEpoch}',
      dealId: dealId,
      senderId: senderId,
      senderName: senderName,
      text: normalizedText,
      createdAt: DateTime.now().toUtc(),
    );
    if (_config.isDemo) {
      _messagesRepository.add(message);
    } else {
      final repository = _liveRepository;
      if (repository == null) throw StateError('Live Supabase repository is unavailable.');
      await repository.sendMessage(dealId: dealId, senderId: senderId, text: normalizedText);
      _liveMessages[dealId] = [...(_liveMessages[dealId] ?? const []), message];
    }
    notifyListeners();
  }

  Future<bool> lockEscrow(String dealId, {String? inspectionPhotoUrl}) async {
    final deal = _requiredDeal(dealId);
    if (deal.status != DealStatus.negotiating) return false;
    if (!_config.isDemo) {
      final repository = _liveRepository;
      final photoUrl = inspectionPhotoUrl?.trim() ?? '';
      if (repository == null) throw StateError('Live Supabase repository is unavailable.');
      if (photoUrl.isEmpty) throw ArgumentError('An inspection photo URL is required before escrow can be locked.');
      final row = await repository.lockDeal(
        dealId: deal.id,
        amount: deal.agreedPrice,
        inspectionPhotoUrl: photoUrl,
        idempotencyKey: 'lock-${deal.id}-${DateTime.now().microsecondsSinceEpoch}',
      );
      _replaceLiveDeal(deal.copyWith(
        status: DealStatusWire.fromWire(row['status'] as String),
        dealLocked: row['deal_locked'] as bool? ?? true,
        openBoxVerified: row['open_box_verified'] as bool? ?? true,
      ));
      notifyListeners();
      return true;
    }
    if (!_wallet.holdEscrow(amount: deal.agreedPrice, dealId: deal.id)) return false;
    _dealsRepository.save(deal.copyWith(
      status: DealStatus.escrowLocked,
      dealLocked: true,
    ));
    notifyListeners();
    return true;
  }

  Future<String> issueDeliveryOtp(String dealId) async {
    if (_config.isDemo) {
      throw UnsupportedError('Delivery OTP is rejected in demo mode.');
    }
    final repository = _liveRepository;
    if (repository == null) {
      throw UnsupportedError('Delivery OTP is issued only by the live server.');
    }
    return repository.issueDeliveryOtp(dealId);
  }

  /// Release is delegated to the server-side `wallet_release` RPC. The client
  /// never compares, stores, or generates the delivery OTP.
  Future<void> requestPayoutRelease({
    required String dealId,
    required String otp,
  }) async {
    if (_config.isDemo) {
      throw UnsupportedError('Payout release is rejected in demo mode.');
    }
    if (otp.trim().length != 6) {
      throw ArgumentError('A six-digit recipient OTP is required.');
    }
    final deal = _requiredDeal(dealId);
    final repository = _liveRepository;
    if (repository == null) {
      throw UnsupportedError('Payout release is available only through the live server.');
    }
    final row = await repository.releaseWallet(
      dealId: dealId,
      otp: otp.trim(),
      idempotencyKey: 'release-$dealId-${DateTime.now().microsecondsSinceEpoch}',
    );
    final updated = deal.copyWith(
      dealLocked: row['deal_locked'] as bool? ?? deal.dealLocked,
      openBoxVerified: row['open_box_verified'] as bool? ?? deal.openBoxVerified,
      status: DealStatusWire.fromWire(row['status'] as String),
    );
    if (_config.isDemo) {
      _dealsRepository.save(updated);
    } else {
      _replaceLiveDeal(updated);
    }
    notifyListeners();
  }


  Future<void> requestRefund(String dealId) async {
    final deal = _requiredDeal(dealId);
    final repository = _liveRepository;
    if (repository == null) {
      throw UnsupportedError('Escrow refund is available only through the live server.');
    }
    if (_config.isDemo) {
      throw UnsupportedError('Escrow refund is rejected in demo mode.');
    }
    final row = await repository.refundWallet(
      dealId: dealId,
      idempotencyKey: 'refund-$dealId-${DateTime.now().microsecondsSinceEpoch}',
    );
    _replaceLiveDeal(deal.copyWith(
      dealLocked: row['deal_locked'] as bool? ?? false,
      openBoxVerified: row['open_box_verified'] as bool? ?? deal.openBoxVerified,
      status: DealStatusWire.fromWire(row['status'] as String),
    ));
    notifyListeners();
  }

  DealModel _requiredDeal(String dealId) {
    for (final deal in deals) {
      if (deal.id == dealId) return deal;
    }
    throw StateError('Unknown deal: $dealId');
  }

  void _replaceLiveDeal(DealModel replacement) {
    _liveDeals = _liveDeals
        .map((deal) => deal.id == replacement.id ? replacement : deal)
        .toList(growable: false);
  }
}
