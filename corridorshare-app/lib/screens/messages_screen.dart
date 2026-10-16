import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/chat/meetup_pin.dart';
import '../core/money/money.dart';
import '../core/theme/app_colors.dart';
import '../models/deal_model.dart';
import '../models/package_model.dart';
import '../providers/user_provider.dart';
import '../widgets/ui.dart';
import 'deal_chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _previewsStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_previewsStarted) return;
    _previewsStarted = true;
    _loadPreviews();
  }

  Future<void> _loadPreviews() async {
    final provider = context.read<UserProvider>();
    for (final deal in provider.deals) {
      try {
        await provider.dealsController.loadMessages(deal.id);
      } on Object {
        // Keep inbox usable even if one deal preview fails.
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PackageModel _packageForDeal(DealModel deal, UserProvider provider) {
    for (final pkg in provider.packages) {
      if (pkg.id == deal.packageId) return pkg;
    }
    for (final pkg in provider.matchedPackages) {
      if (pkg.id == deal.packageId) return pkg;
    }
    // Display stub when the listing is outside the current listings cache.
    return PackageModel(
      id: deal.packageId,
      senderId: deal.senderId,
      itemDescription: deal.packageItem,
      reward: deal.agreedPrice.isPositive ? deal.agreedPrice : Money.fromBdt(1),
      status: PackageStatus.matched,
      pickup: const GeoPoint(23.8103, 90.4125),
      dropoff: const GeoPoint(24.3636, 88.6241),
      pickupRadiusMeters: 2000,
      distanceFromCorridor: 0,
      isNearMiss: false,
      routeInfo: deal.routeInfo,
      eta: DateTime.now().toUtc(),
      itemType: deal.packageItem,
    );
  }

  String _previewFor(DealModel deal, UserProvider provider) {
    final messages = provider.dealsController.messagesFor(deal.id);
    if (messages.isEmpty) return 'No messages yet';
    return MeetupPin.previewOrText(messages.last.text);
  }

  List<DealModel> _filteredDeals(UserProvider provider) {
    final q = _query.trim().toLowerCase();
    final deals = provider.deals;
    if (q.isEmpty) return deals;
    return deals.where((deal) {
      final preview = _previewFor(deal, provider).toLowerCase();
      return deal.packageItem.toLowerCase().contains(q) ||
          deal.packageId.toLowerCase().contains(q) ||
          deal.id.toLowerCase().contains(q) ||
          deal.routeInfo.toLowerCase().contains(q) ||
          deal.status.label.toLowerCase().contains(q) ||
          preview.contains(q);
    }).toList(growable: false);
  }

  StatusTone _statusTone(DealStatus status) => switch (status) {
        DealStatus.negotiating => StatusTone.neutral,
        DealStatus.escrowLocked => StatusTone.pending,
        DealStatus.inTransit => StatusTone.pending,
        DealStatus.completed => StatusTone.ok,
        DealStatus.cancelled => StatusTone.danger,
      };

  IconData _statusIcon(DealStatus status) => switch (status) {
        DealStatus.negotiating => Icons.forum_outlined,
        DealStatus.escrowLocked => Icons.lock_outline,
        DealStatus.inTransit => Icons.local_shipping_outlined,
        DealStatus.completed => Icons.check_circle_outline,
        DealStatus.cancelled => Icons.cancel_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final deals = _filteredDeals(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Deals')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search deals',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: 'Clear',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: deals.isEmpty
                ? EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: userProvider.deals.isEmpty
                        ? 'No deals yet'
                        : 'No results',
                    message: userProvider.deals.isEmpty
                        ? 'Open a deal from Matching, or request space on a trip from Home.'
                        : 'Nothing matches “$_query”.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: deals.length,
                    separatorBuilder: (_, __) => const Divider(indent: 72),
                    itemBuilder: (ctx, idx) {
                      final deal = deals[idx];
                      final pkg = _packageForDeal(deal, userProvider);
                      final preview = _previewFor(deal, userProvider);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        leading: InitialsAvatar(deal.packageItem, radius: 20),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                deal.packageItem,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Gap.sm,
                            Text(
                              '৳ ${deal.agreedPrice.asBdt.toStringAsFixed(0)}',
                              style: context.tt.titleSmall,
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(preview,
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              Gap.xs,
                              StatusText(
                                deal.status.label,
                                tone: _statusTone(deal.status),
                                icon: _statusIcon(deal.status),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DealChatScreen(
                                package: pkg,
                                dealId: deal.id,
                                tripId: deal.tripId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
