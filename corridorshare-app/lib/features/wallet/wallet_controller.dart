import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';
import '../../core/money/money.dart';

enum WalletTransactionType { topUp, escrowHold, escrowRelease, refund }

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.createdAt,
    required this.reference,
  });

  final String id;
  final WalletTransactionType type;
  final Money amount;
  final DateTime createdAt;
  final String reference;
}

class WalletController extends ChangeNotifier {
  WalletController({required AppConfig config})
      : _config = config,
        _availableBalance = config.isDemo ? Money.fromBdt(12450) : Money.zero,
        _escrowBalance = config.isDemo ? Money.fromBdt(1800) : Money.zero;

  final AppConfig _config;
  Money _availableBalance;
  Money _escrowBalance;
  final List<WalletTransaction> _transactions = [];

  Money get availableBalance => _availableBalance;
  Money get escrowBalance => _escrowBalance;
  Money get totalBalance => _availableBalance + _escrowBalance;
  List<WalletTransaction> get transactions => List.unmodifiable(_transactions);

  void applyServerBalances({required int availableMinor, required int heldMinor}) {
    if (_config.isDemo) throw StateError('Server balances are unavailable in demo mode.');
    _availableBalance = Money.fromMinorUnits(availableMinor);
    _escrowBalance = Money.fromMinorUnits(heldMinor);
    notifyListeners();
  }

  void topUp({required Money amount, required String provider}) {
    _requireDemoMutation();
    _availableBalance += amount;
    _record(WalletTransactionType.topUp, amount, provider);
    notifyListeners();
  }

  bool holdEscrow({required Money amount, required String dealId}) {
    _requireDemoMutation();
    if (amount.compareTo(_availableBalance) > 0) return false;
    _availableBalance -= amount;
    _escrowBalance += amount;
    _record(WalletTransactionType.escrowHold, amount, dealId);
    notifyListeners();
    return true;
  }

  bool releaseEscrow({required Money amount, required String dealId}) {
    _requireDemoMutation();
    if (amount.compareTo(_escrowBalance) > 0) return false;
    _escrowBalance -= amount;
    _record(WalletTransactionType.escrowRelease, amount, dealId);
    notifyListeners();
    return true;
  }

  void _record(WalletTransactionType type, Money amount, String reference) {
    _transactions.insert(
      0,
      WalletTransaction(
        id: 'wallet-${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        amount: amount,
        createdAt: DateTime.now().toUtc(),
        reference: reference,
      ),
    );
  }

  void _requireDemoMutation() {
    if (!_config.isDemo) {
      throw StateError('Wallet changes must be authorized by a server-side command in live mode.');
    }
  }
}
