import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'deal_chat_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final packages = userProvider.packages;

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
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search chats, package IDs, or traveler names...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                        border: InputBorder.none,
                      ),
                    ),
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
              child: ListView.builder(
                itemCount: packages.length,
                itemBuilder: (ctx, idx) {
                  final pkg = packages[idx];
                  final isEven = idx % 2 == 0;

                  return Card(
                    color: const Color(0xFF0F172A),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isEven ? Colors.orange.withValues(alpha: 0.3) : Colors.white10,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.orange.withValues(alpha: 0.2),
                            child: const Icon(Icons.person, color: Colors.orangeAccent),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF059669),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF0F172A), width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pkg.itemDescription,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            '৳ ${pkg.proposedReward.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            isEven
                                ? 'Traveler: "I will pick up near Gazipur at 4 PM."'
                                : 'Sender: "Is open-box verification code ready?"',
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
                                  color: isEven ? Colors.amber.withValues(alpha: 0.2) : const Color(0xFF059669).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isEven ? '🔒 Escrow Locked' : '💬 Negotiating',
                                  style: TextStyle(
                                    color: isEven ? Colors.amberAccent : Colors.greenAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('ID: ${pkg.id}', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DealChatScreen(package: pkg),
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
