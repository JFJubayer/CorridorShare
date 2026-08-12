import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/geo/bangladesh_geo.dart';
import '../core/config/app_config.dart';
import '../providers/user_provider.dart';
import '../widgets/surcharge_calculator.dart';
import 'match_screen.dart';
import 'deal_chat_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showPostModal(BuildContext context, bool isTraveler) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final descController = TextEditingController(text: 'Documents Envelope');
    final rewardController = TextEditingController(text: '450');
    final weightController = TextEditingController(text: '5.0');
    final recipientController = TextEditingController();
    String? departureId = BangladeshGeo.places.first.id;
    String? destinationId = BangladeshGeo.places[1].id;
    String? pickupId = BangladeshGeo.places.first.id;
    String? dropoffId = BangladeshGeo.places[5].id;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTraveler ? 'Post Bangladesh Highway Trip' : 'Request Parcel Shipping',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Geometry comes from your selected places — not a hardcoded N3 LINESTRING.',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    if (isTraveler) ...[
                      DropdownButtonFormField<String>(
                        initialValue: departureId,
                        dropdownColor: const Color(0xFF0F172A),
                        decoration: const InputDecoration(
                          labelText: 'Departure (Bangladesh)',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                        ),
                        items: BangladeshGeo.places
                            .map((p) => DropdownMenuItem(value: p.id, child: Text('${p.label} (${p.region})', style: const TextStyle(color: Colors.white, fontSize: 12))))
                            .toList(),
                        onChanged: (v) => setModalState(() => departureId = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: destinationId,
                        dropdownColor: const Color(0xFF0F172A),
                        decoration: const InputDecoration(
                          labelText: 'Destination (Bangladesh)',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                        ),
                        items: BangladeshGeo.places
                            .map((p) => DropdownMenuItem(value: p.id, child: Text('${p.label} (${p.region})', style: const TextStyle(color: Colors.white, fontSize: 12))))
                            .toList(),
                        onChanged: (v) => setModalState(() => destinationId = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Available Capacity (KG)',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: descController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Parcel Item Description',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: pickupId,
                        dropdownColor: const Color(0xFF0F172A),
                        decoration: const InputDecoration(
                          labelText: 'Pickup place',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                        ),
                        items: BangladeshGeo.places
                            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.label, style: const TextStyle(color: Colors.white, fontSize: 12))))
                            .toList(),
                        onChanged: (v) => setModalState(() => pickupId = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: dropoffId,
                        dropdownColor: const Color(0xFF0F172A),
                        decoration: const InputDecoration(
                          labelText: 'Dropoff place (must differ)',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                        ),
                        items: BangladeshGeo.places
                            .map((p) => DropdownMenuItem(value: p.id, child: Text(p.label, style: const TextStyle(color: Colors.white, fontSize: 12))))
                            .toList(),
                        onChanged: (v) => setModalState(() => dropoffId = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: rewardController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Proposed Surcharge Reward (BDT)',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Weight (KG)',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: recipientController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Recipient phone (required)',
                          labelStyle: TextStyle(color: Colors.grey),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final capacity = double.tryParse(weightController.text);
                          final reward = double.tryParse(rewardController.text);
                          try {
                            if (isTraveler) {
                              if (capacity == null || capacity <= 0) {
                                throw ArgumentError('Capacity must be a positive number.');
                              }
                              final dep = BangladeshGeo.byId(departureId ?? '');
                              final dest = BangladeshGeo.byId(destinationId ?? '');
                              if (dep == null || dest == null) {
                                throw ArgumentError('Select valid Bangladesh places.');
                              }
                              final route = BangladeshGeo.routeBetween(dep, dest);
                              await provider.addTrip(
                                departure: dep.label,
                                destination: dest.label,
                                date: 'soon',
                                capacity: capacity,
                                routePoints: route,
                              );
                            } else {
                              if (reward == null || reward <= 0) {
                                throw ArgumentError('Reward must be a positive amount.');
                              }
                              if (capacity == null || capacity <= 0) {
                                throw ArgumentError('Weight must be a positive number.');
                              }
                              final pickup = BangladeshGeo.byId(pickupId ?? '');
                              final dropoff = BangladeshGeo.byId(dropoffId ?? '');
                              if (pickup == null || dropoff == null) {
                                throw ArgumentError('Select valid pickup and dropoff places.');
                              }
                              if (pickup.id == dropoff.id) {
                                throw ArgumentError('Dropoff must differ from pickup.');
                              }
                              final phone = recipientController.text.trim();
                              if (phone.isEmpty) {
                                throw ArgumentError('Recipient phone is required.');
                              }
                              await provider.addPackage(
                                desc: descController.text,
                                weight: capacity,
                                reward: reward,
                                pickup: pickup.point,
                                dropoff: dropoff.point,
                                routeInfo: '${pickup.label} → ${dropoff.label}',
                                recipientPhone: phone,
                              );
                            }
                          } on Object catch (error) {
                            if (!ctx.mounted) return;
                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$error')));
                            return;
                          }
                          if (!ctx.mounted || !context.mounted) return;
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isTraveler ? 'Trip posted with live geometry!' : 'Delivery request posted!'),
                              backgroundColor: const Color(0xFF059669),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
                        child: Text(
                          isTraveler ? 'POST TRIP' : 'SUBMIT REQUEST',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      descController.dispose();
      rewardController.dispose();
      weightController.dispose();
      recipientController.dispose();
    });
  }

  void _showTopUpDialog(BuildContext context, String providerName, Color themeColor) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final amountController = TextEditingController(text: '500');

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: themeColor.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(Icons.account_balance_wallet, color: themeColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text('$providerName Top Up', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter amount to deposit via $providerName mobile wallet:', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              const SizedBox(height: 14),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.w900),
                decoration: InputDecoration(
                  prefixText: '৳ ',
                  prefixStyle: const TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.w900),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: themeColor)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: themeColor, width: 2)),
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
              onPressed: () async {
                final amt = double.tryParse(amountController.text);
                if (amt == null || amt <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Top-up amount must be positive.')));
                  return;
                }
                if (userProvider.dataMode == AppDataMode.supabase) {
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Live $providerName top-up is blocked: no payment provider is configured. '
                        'Escrow lock/release still work when the wallet is already funded.',
                      ),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  );
                  return;
                }
                try {
                  if (providerName == 'bKash') {
                    await userProvider.topUpBkash(amt);
                  } else {
                    await userProvider.topUpNagad(amt);
                  }
                } on Object catch (error) {
                  if (!ctx.mounted) return;
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('$error')));
                  return;
                }
                if (!ctx.mounted || !context.mounted) return;
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ৳${amt.toStringAsFixed(0)} via $providerName!'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: themeColor),
              child: const Text('CONFIRM TOP UP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).whenComplete(amountController.dispose);
  }


  Future<void> _uploadNidPhoto(BuildContext context) async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    if (provider.dataMode != AppDataMode.supabase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NID photo upload requires live Supabase mode.')),
      );
      return;
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      await provider.uploadNidPhoto(
        bytes: bytes,
        fileName: 'nid-${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('NID photo uploaded to Storage and marked pending for admin review.'),
          backgroundColor: Color(0xFF059669),
        ),
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$error'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF051424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF051424),
        elevation: 0,
        toolbarHeight: 64,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF1C2B3C),
              child: Icon(Icons.person, color: Color(0xFFFFB690), size: 20),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                children: [
                  TextSpan(text: 'Corridor', style: TextStyle(color: Color(0xFFFFB690))),
                  TextSpan(text: 'Share', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => _uploadNidPhoto(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF68DBA9).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF68DBA9).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Color(0xFF68DBA9), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'NID ${userProvider.nidStatus}',
                    style: const TextStyle(color: Color(0xFF68DBA9), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton.icon(
              onPressed: userProvider.toggleRole,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1C2B3C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              icon: Icon(
                userProvider.isTraveler ? Icons.directions_car : Icons.inventory_2,
                color: const Color(0xFFF97316),
                size: 16,
              ),
              label: Text(
                userProvider.isTraveler ? 'Traveler' : 'Sender',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF122131)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.25),
                        children: [
                          TextSpan(text: 'Monetize Your ', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'Journey.\n', style: TextStyle(color: Color(0xFFF97316))),
                          TextSpan(text: 'Secure Your ', style: TextStyle(color: Colors.white)),
                          TextSpan(text: 'Parcel.', style: TextStyle(color: Color(0xFFF97316))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Bangladesh\'s first secure peer-to-peer delivery network for daily commuters.',
                      style: TextStyle(color: Color(0xFFE0C0B1), fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SurchargeCalculatorWidget(
                onShipPressed: () => _showPostModal(context, userProvider.isTraveler),
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('ESCROW BALANCE', style: TextStyle(color: Color(0xFFE0C0B1), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        Icon(Icons.account_balance_wallet, color: Color(0xFFE0C0B1), size: 22),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '৳ ${userProvider.walletBalance.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2B3C),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Active Escrow', style: TextStyle(color: Color(0xFFE0C0B1), fontSize: 10)),
                                const SizedBox(height: 2),
                                Text('৳ ${userProvider.escrowLockedBalance.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF68DBA9), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1C2B3C),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1E293B)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Available', style: TextStyle(color: Color(0xFFE0C0B1), fontSize: 10)),
                                const SizedBox(height: 2),
                                Text('৳ ${(userProvider.walletBalance - userProvider.escrowLockedBalance).toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (userProvider.dataMode != AppDataMode.demo)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Live top-up blocked: no payment provider. Staging funding uses admin_credit_wallet.',
                          style: TextStyle(color: Colors.amberAccent, fontSize: 11),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: userProvider.dataMode.name == 'demo'
                                ? () => _showTopUpDialog(context, 'bKash', Colors.pinkAccent)
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Live top-up blocked: no payment provider. Ask an admin to run admin_credit_wallet.',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Top Up via bKash', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: userProvider.dataMode.name == 'demo'
                                ? () => _showTopUpDialog(context, 'Nagad', Colors.deepOrangeAccent)
                                : () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Live top-up blocked: no payment provider. Ask an admin to run admin_credit_wallet.',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Top Up via Nagad', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dhaka-Mymensingh Corridor', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MatchScreen())),
                    child: const Text('View All', style: TextStyle(color: Color(0xFFF97316), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 175,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: userProvider.trips.length,
                  itemBuilder: (ctx, idx) {
                    final trip = userProvider.trips[idx];

                    return Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2B3C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: const Color(0xFF0F172A),
                                      child: Text(trip.travelerName[0], style: const TextStyle(color: Color(0xFF68DBA9), fontWeight: FontWeight.bold, fontSize: 11)),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(trip.travelerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star, color: Color(0xFF68DBA9), size: 10),
                                                const SizedBox(width: 2),
                                                Text(trip.travelerRatingLabel, style: const TextStyle(color: Color(0xFF68DBA9), fontSize: 9, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF97316).withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                child: Text(trip.travelTimeLabel, style: const TextStyle(color: Color(0xFFFFB690), fontSize: 9, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.grey, size: 12),
                              const SizedBox(width: 4),
                              Expanded(child: Text(trip.departureCity, style: const TextStyle(color: Colors.white, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.navigation, color: Color(0xFFF97316), size: 12),
                              const SizedBox(width: 4),
                              Expanded(child: Text(trip.destinationCity, style: const TextStyle(color: Colors.white, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),

                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Up to ${trip.weightCapacityKg.toStringAsFixed(0)}kg', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                              GestureDetector(
                                onTap: () {
                                  final dummyPkg = userProvider.packages.first;
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => DealChatScreen(package: dummyPkg)));
                                },
                                child: const Text('Request', style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold, fontSize: 11)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              const Text('How It Works', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              _buildStitchStepCard(
                Icons.handshake,
                '1. Match & Negotiate',
                'Connect with verified travelers on your corridor and agree on terms.',
              ),
              const SizedBox(height: 10),
              _buildStitchStepCard(
                Icons.inventory_2,
                '2. Open-Box Inspection',
                'Both parties inspect and photograph items before locking the handover.',
              ),
              const SizedBox(height: 10),
              _buildStitchStepCard(
                Icons.verified_user,
                '3. Secure Payout',
                'Funds are released from escrow only after OTP confirmation at delivery.',
              ),
              const SizedBox(height: 24),

              const Text('Safety & Verification Matrix', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildMatrixTile(Icons.verified, 'NID Verification', const Color(0xFF68DBA9)),
                  _buildMatrixTile(Icons.inventory_2, 'Open-Box Guarantee', const Color(0xFFF97316)),
                  _buildMatrixTile(Icons.security, 'Escrow Security', const Color(0xFF68DBA9)),
                  _buildMatrixTile(Icons.my_location, 'Real-time Tracking', const Color(0xFFF97316)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStitchStepCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFF97316), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: Color(0xFFE0C0B1), fontSize: 11, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixTile(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
