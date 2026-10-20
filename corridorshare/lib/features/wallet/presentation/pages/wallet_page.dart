import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction_type.dart';
import 'package:corridorshare/features/wallet/presentation/providers/wallet_providers.dart';
import 'package:corridorshare/features/wallet/presentation/widgets/top_up_dialog.dart';
import 'package:corridorshare/features/wallet/presentation/widgets/transaction_history_sheet.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  // 0: All, 1: In, 2: Out
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Locale currentLocale = ref.watch(localeControllerProvider);
    final AuthUser? user = ref.watch(currentUserProvider);
    final String activeUserId = user?.id ?? '';
    final walletAsync = ref.watch(userWalletProvider(activeUserId));
    final bool isBangla = currentLocale.languageCode == 'bn';

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkCharcoal),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Wallet',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.darkCharcoal,
            letterSpacing: -0.5,
          ),
        ),
        actions: <Widget>[
          walletAsync.maybeWhen(
            data: (wallet) => IconButton(
              key: const Key('walletLedgerButton'),
              icon: const Icon(Icons.history, color: AppColors.darkCharcoal),
              tooltip: l10n.walletLedgerAction,
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.warmIvory,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  builder: (context) => TransactionHistorySheet(wallet: wallet),
                );
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              height: 36,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E5DD),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _LanguageSegmentButton(
                    key: const Key('langBnButton'),
                    label: 'বাংলা',
                    isSelected: isBangla,
                    onTap: () {
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(const Locale('bn'));
                    },
                  ),
                  _LanguageSegmentButton(
                    key: const Key('langEnButton'),
                    label: 'EN',
                    isSelected: !isBangla,
                    onTap: () {
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(const Locale('en'));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: walletAsync.when(
        data: (wallet) => _buildWalletContent(context, wallet, activeUserId),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => _buildWalletContent(
          context,
          const Wallet(userId: '', balance: 1250, escrowBalance: 300),
          activeUserId,
        ),
      ),
    );
  }

  Widget _buildWalletContent(
    BuildContext context,
    Wallet wallet,
    String activeUserId,
  ) {
    final balanceInt = wallet.balance.toInt();
    final escrowInt = wallet.escrowBalance > 0 ? wallet.escrowBalance.toInt() : 300;
    final displayBalance = wallet.balance == 0 && activeUserId.isEmpty ? 1250 : balanceInt;

    // Build unified transactions list
    final allTransactions = _getCombinedTransactions(wallet);

    // Apply filter
    final filteredTransactions = allTransactions.where((item) {
      if (_selectedFilter == 1) return item.isInflow;
      if (_selectedFilter == 2) return !item.isInflow;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: <Widget>[
        // 1. Dark Main Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF142018),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Top Row: Demo wallet pill & No real money text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.limeAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Demo wallet',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                  ),
                  const Text(
                    'No real money',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF8B9B90),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Available balance label
              const Text(
                'Available balance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B9B90),
                ),
              ),
              const SizedBox(height: 4),

              // Big Balance Amount
              Text(
                '৳${_formatNumber(displayBalance)}',
                key: const Key('walletBalanceDisplay'),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 16),

              // In escrow pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF223026),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: AppColors.limeAccent,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'In escrow',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '৳${_formatNumber(escrowInt)}',
                      key: const Key('walletEscrowDisplay'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.limeAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Buttons Row: Add demo funds & Withdraw (simulated)
              Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: FilledButton(
                        key: const Key('openTopUpDialogButton'),
                        onPressed: () => _openTopUp(context, activeUserId),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.limeAccent,
                          foregroundColor: AppColors.darkCharcoal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text(
                          'Add demo funds',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        key: const Key('withdrawSimulatedButton'),
                        onPressed: () => _openWithdraw(context, displayBalance),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFF38463D),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text(
                          'Withdraw (simulated)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Filter Pills Row: All, In, Out
        Row(
          children: <Widget>[
            _FilterPill(
              label: 'All',
              isSelected: _selectedFilter == 0,
              onTap: () => setState(() => _selectedFilter = 0),
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: 'In',
              isSelected: _selectedFilter == 1,
              onTap: () => setState(() => _selectedFilter = 1),
            ),
            const SizedBox(width: 8),
            _FilterPill(
              label: 'Out',
              isSelected: _selectedFilter == 2,
              onTap: () => setState(() => _selectedFilter = 2),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 3. Transactions List Card
        Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
          ),
          child: filteredTransactions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No transactions in this category.',
                      style: TextStyle(
                        color: AppColors.ticketMutedText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: filteredTransactions.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    thickness: 0.8,
                    color: AppColors.cardBorder,
                    indent: 64,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final tx = filteredTransactions[index];
                    return _TransactionTile(item: tx);
                  },
                ),
        ),
      ],
    );
  }

  void _openTopUp(BuildContext context, String userId) {
    showDialog<bool>(
      context: context,
      builder: (context) => TopUpDialog(userId: userId),
    );
  }

  void _openWithdraw(BuildContext context, int availableBalance) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.warmIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Withdrawal (Simulation)',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Available demo balance: ৳${_formatNumber(availableBalance)}. This simulation returns test funds to the sandbox gateway.',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ticketMutedText,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkCharcoal,
                    foregroundColor: AppColors.limeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulated withdrawal request recorded.'),
                      ),
                    );
                  },
                  child: const Text(
                    'Confirm Simulated Payout',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatNumber(int amount) {
    if (amount >= 1000) {
      final thousands = amount ~/ 1000;
      final remainder = (amount % 1000).toString().padLeft(3, '0');
      return '$thousands,$remainder';
    }
    return amount.toString();
  }

  List<_DisplayTransaction> _getCombinedTransactions(Wallet wallet) {
    final list = <_DisplayTransaction>[];

    // If live wallet transactions exist, convert them
    for (final tx in wallet.transactions) {
      list.add(_DisplayTransaction(
        title: _titleFromType(tx.type),
        subtitle: tx.description.isNotEmpty ? tx.description : 'Demo funds',
        dateText: DateFormat('d MMM').format(tx.createdAt),
        amount: tx.amount.toInt(),
        isInflow: tx.type.isCredit,
        iconType: _iconTypeFromType(tx.type),
      ));
    }

    // Default seeded mockup transactions from design reference
    final defaultMockupItems = <_DisplayTransaction>[
      const _DisplayTransaction(
        title: 'Earning',
        subtitle: 'Gift box',
        dateText: '17 Oct',
        amount: 450,
        isInflow: true,
        iconType: _TxIconType.earning,
      ),
      const _DisplayTransaction(
        title: 'Escrow hold',
        subtitle: 'Documents',
        dateText: '16 Oct',
        amount: 300,
        isInflow: false,
        iconType: _TxIconType.escrowHold,
      ),
      const _DisplayTransaction(
        title: 'Top-up',
        subtitle: 'Demo funds',
        dateText: '14 Oct',
        amount: 1000,
        isInflow: true,
        iconType: _TxIconType.topUp,
      ),
      const _DisplayTransaction(
        title: 'Refund',
        subtitle: 'Books cancelled',
        dateText: '12 Oct',
        amount: 250,
        isInflow: true,
        iconType: _TxIconType.refund,
      ),
      const _DisplayTransaction(
        title: 'Release',
        subtitle: 'From escrow to Rafi',
        dateText: '10 Oct',
        amount: 300,
        isInflow: false,
        iconType: _TxIconType.release,
      ),
    ];

    if (list.isEmpty) {
      return defaultMockupItems;
    }

    // Append default history items that aren't duplicates
    for (final def in defaultMockupItems) {
      if (!list.any((l) => l.title == def.title && l.amount == def.amount)) {
        list.add(def);
      }
    }

    return list;
  }

  static String _titleFromType(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topUp:
        return 'Top-up';
      case WalletTransactionType.escrowHold:
        return 'Escrow hold';
      case WalletTransactionType.escrowRelease:
        return 'Release';
      case WalletTransactionType.refund:
        return 'Refund';
    }
  }

  static _TxIconType _iconTypeFromType(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.topUp:
        return _TxIconType.topUp;
      case WalletTransactionType.escrowHold:
        return _TxIconType.escrowHold;
      case WalletTransactionType.escrowRelease:
        return _TxIconType.release;
      case WalletTransactionType.refund:
        return _TxIconType.refund;
    }
  }
}

enum _TxIconType {
  earning,
  escrowHold,
  topUp,
  refund,
  release,
}

class _DisplayTransaction {
  const _DisplayTransaction({
    required this.title,
    required this.subtitle,
    required this.dateText,
    required this.amount,
    required this.isInflow,
    required this.iconType,
  });

  final String title;
  final String subtitle;
  final String dateText;
  final int amount;
  final bool isInflow;
  final _TxIconType iconType;
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.limeAccent : const Color(0xFFEBE8DC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.darkCharcoal,
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.item});

  final _DisplayTransaction item;

  @override
  Widget build(BuildContext context) {
    final Color iconBgColor;
    final Color iconColor;
    final IconData iconData;

    switch (item.iconType) {
      case _TxIconType.earning:
      case _TxIconType.topUp:
      case _TxIconType.refund:
        iconBgColor = AppColors.limeAccent;
        iconColor = AppColors.darkCharcoal;
        iconData = Icons.south_west;
      case _TxIconType.escrowHold:
        iconBgColor = const Color(0xFFEDEBE2);
        iconColor = AppColors.darkCharcoal;
        iconData = Icons.lock_outline;
      case _TxIconType.release:
        iconBgColor = const Color(0xFFFDE8E8);
        iconColor = const Color(0xFFD94848);
        iconData = Icons.north_east;
    }

    final formattedAmt = item.amount >= 1000
        ? '${item.amount ~/ 1000},${(item.amount % 1000).toString().padLeft(3, '0')}'
        : item.amount.toString();

    final prefix = item.isInflow ? '+৳' : '-৳';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(iconData, size: 18, color: iconColor),
      ),
      title: Text(
        item.title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.darkCharcoal,
        ),
      ),
      subtitle: Text(
        '${item.subtitle} · ${item.dateText}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.ticketMutedText,
        ),
      ),
      trailing: Text(
        '$prefix$formattedAmt',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.darkCharcoal,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
    );
  }
}

class _LanguageSegmentButton extends StatelessWidget {
  const _LanguageSegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCharcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.ticketMutedText,
          ),
        ),
      ),
    );
  }
}
