import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/package_model.dart';
import '../models/deal_model.dart';
import '../providers/user_provider.dart';

class DealChatScreen extends StatefulWidget {
  final PackageModel package;
  const DealChatScreen({super.key, required this.package});

  @override
  State<DealChatScreen> createState() => _DealChatScreenState();
}

class _DealChatScreenState extends State<DealChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  late DealModel _deal;

  @override
  void initState() {
    super.initState();
    _deal = DealModel(
      id: 'deal-${widget.package.id}',
      tripId: 'trip-101',
      packageId: widget.package.id,
      travelerId: 't-101',
      senderId: widget.package.senderId,
      agreedPrice: widget.package.proposedReward,
      status: 'Negotiating',
      otpSecret: '8821',
      chatMessages: [
        ChatMessageModel(
          id: 'm1',
          dealId: 'deal-${widget.package.id}',
          senderId: widget.package.senderId,
          senderName: 'Sender',
          text: 'Hi! Can you carry "${widget.package.itemDescription}" along N3 Corridor?',
          isMe: false,
          timestamp: '2:15 PM',
        ),
        ChatMessageModel(
          id: 'm2',
          dealId: 'deal-${widget.package.id}',
          senderId: 't-101',
          senderName: 'Ahmed R.',
          text: 'Yes, I am leaving Uttara at 2:30 PM. I can take it for ৳${widget.package.proposedReward.toStringAsFixed(0)}.',
          isMe: true,
          timestamp: '2:16 PM',
        ),
      ],
    );
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _deal.chatMessages.add(
        ChatMessageModel(
          id: 'm-${DateTime.now().millisecondsSinceEpoch}',
          dealId: _deal.id,
          senderId: userProvider.userId,
          senderName: 'You',
          text: text,
          isMe: true,
          timestamp: 'Just now',
        ),
      );
      _msgController.clear();
    });
  }

  void _lockEscrow() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = userProvider.deductWallet(_deal.agreedPrice);

    if (success) {
      setState(() {
        _deal.status = 'Escrow Locked 🔒';
        _deal.dealLocked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('৳${_deal.agreedPrice.toStringAsFixed(0)} locked safely in CorridorShare Escrow!'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient wallet balance! Please top up via bKash or Nagad.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _releasePayout() {
    final otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Text('Open-Box Delivery OTP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter 4-digit recipient verification OTP:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 12),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  hintText: '8821',
                  hintStyle: TextStyle(color: Colors.white24),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                userProvider.releaseEscrowPayout(_deal.agreedPrice);
                setState(() {
                  _deal.status = 'Completed ✅';
                  _deal.openBoxVerified = true;
                });
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('OTP Verified! ৳${_deal.agreedPrice.toStringAsFixed(0)} payout released to traveler.'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
              child: const Text('VERIFY & RELEASE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF051424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.package.itemDescription, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text('Deal ID: ${_deal.packageId} • ${_deal.status}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Escrow Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1E293B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Agreed Surcharge Reward', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('৳ ${_deal.agreedPrice.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
                if (_deal.status == 'Negotiating')
                  ElevatedButton.icon(
                    onPressed: _lockEscrow,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
                    icon: const Icon(Icons.lock, color: Colors.white, size: 16),
                    label: const Text('Lock Escrow', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else if (_deal.status == 'Escrow Locked 🔒')
                  ElevatedButton.icon(
                    onPressed: _releasePayout,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                    icon: const Icon(Icons.verified_user, color: Colors.white, size: 16),
                    label: const Text('Release Payout', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF059669).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Text('Completed ✓', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _deal.chatMessages.length,
              itemBuilder: (ctx, idx) {
                final msg = _deal.chatMessages[idx];
                final isMe = msg.senderId == userProvider.userId || msg.isMe;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFF97316) : const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isMe ? Colors.orangeAccent : Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3)),
                        const SizedBox(height: 4),
                        Text(msg.timestamp, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 9)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Type message or negotiation terms...',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFFF97316)),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
