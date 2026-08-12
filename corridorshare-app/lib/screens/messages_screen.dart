import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/chat/meetup_pin.dart';
import '../core/money/money.dart';
import '../models/deal_model.dart';
import '../models/package_model.dart';
import '../providers/user_provider.dart';
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
    if (messages.isEmpty) return 'No messages yet — open to negotiate.';
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

  Color _statusColor(DealStatus status) => switch (status) {
        DealStatus.negotiating => Colors.greenAccent,
        DealStatus.escrowLocked => Colors.amberAccent,
        DealStatus.inTransit => Colors.lightBlueAccent,
        DealStatus.completed => const Color(0xFF68DBA9),
        DealStatus.cancelled => Colors.redAccent,
      };

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final deals = _filteredDeals(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF051424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text('Deal Messages & Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search deals, package IDs, or message previews...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Active Deal Rooms',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: deals.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          userProvider.deals.isEmpty
                              ? 'No deal chats yet.\nMatch a package on Matching or request capacity from a trip to start negotiating.'
                              : 'No deals match “$_query”.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: deals.length,
                      itemBuilder: (ctx, idx) {
                        final deal = deals[idx];
                        final pkg = _packageForDeal(deal, userProvider);
                        final preview = _previewFor(deal, userProvider);
                        final statusColor = _statusColor(deal.status);

                        return Card(
                          color: const Color(0xFF0F172A),
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: statusColor.withValues(alpha: 0.35)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.orange.withValues(alpha: 0.2),
                              child: const Icon(Icons.chat_bubble_outline, color: Colors.orangeAccent),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    deal.packageItem,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '৳ ${deal.agreedPrice.asBdt.toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 14),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  preview,
                                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        deal.status.label,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Deal ${deal.id}',
                                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
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
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
