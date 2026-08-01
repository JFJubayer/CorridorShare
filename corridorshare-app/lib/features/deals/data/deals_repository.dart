import '../../../models/deal_model.dart';

abstract interface class DealsRepository {
  DealModel? findByPackageId(String packageId);
  List<DealModel> get all;
  void save(DealModel deal);
}

abstract interface class MessagesRepository {
  List<ChatMessageModel> forDeal(String dealId);
  void add(ChatMessageModel message);
}

class FakeDealsRepository implements DealsRepository {
  final List<DealModel> _deals = [];

  @override
  List<DealModel> get all => List.unmodifiable(_deals);

  @override
  DealModel? findByPackageId(String packageId) {
    for (final deal in _deals) {
      if (deal.packageId == packageId) return deal;
    }
    return null;
  }

  @override
  void save(DealModel deal) {
    final index = _deals.indexWhere((existing) => existing.id == deal.id);
    if (index == -1) {
      _deals.add(deal);
    } else {
      _deals[index] = deal;
    }
  }
}

class FakeMessagesRepository implements MessagesRepository {
  final Map<String, List<ChatMessageModel>> _messagesByDeal = {};

  @override
  List<ChatMessageModel> forDeal(String dealId) =>
      List.unmodifiable(_messagesByDeal[dealId] ?? const []);

  @override
  void add(ChatMessageModel message) {
    _messagesByDeal.putIfAbsent(message.dealId, () => []).add(message);
  }
}
