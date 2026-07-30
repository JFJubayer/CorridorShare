import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/package_model.dart';
import '../widgets/map_corridor.dart';
import 'deal_chat_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  PackageModel? _selectedPackage;

  void _showDetourDialog(PackageModel pkg) {
    final offerController = TextEditingController(text: (pkg.proposedReward + 100).toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: Row(
            children: const [
              Icon(Icons.alt_route, color: Colors.orangeAccent, size: 22),
              SizedBox(width: 8),
              Text('Near-Miss Detour Offer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This package is ${pkg.distanceFromCorridor.toStringAsFixed(0)} meters off your main corridor. Propose a detour compensation bonus:',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: offerController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '৳ ',
                  prefixStyle: TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.bold),
                  labelText: 'Offered Reward (BDT)',
                  labelStyle: TextStyle(color: Colors.grey),
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
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DealChatScreen(package: pkg),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
              child: const Text('SEND OFFER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        title: const Text('Dhaka–Mymensingh (N3) Corridor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Column(
        children: [
          // Map Container
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            child: MapCorridorWidget(
              packages: userProvider.packages,
              onPackageTap: (pkg) {
                setState(() {
                  _selectedPackage = pkg;
                });
              },
            ),
          ),

          // Match Results Header
          Container(
            padding: const EdgeInsets.all(14),
            color: const Color(0xFF0F172A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.orangeAccent, size: 20),
                    const SizedBox(width: 6),
                    Text('${userProvider.packages.length} Active Matches', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Geofence Active (5km)', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Matches List View
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: userProvider.packages.length,
              itemBuilder: (ctx, idx) {
                final pkg = userProvider.packages[idx];
                final isSelected = _selectedPackage?.id == pkg.id;

                return Card(
                  color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: pkg.isNearMiss ? Colors.amber : (isSelected ? Colors.orange : Colors.white10),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(pkg.itemDescription, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                if (pkg.isPremium) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                                    child: const Text('URGENT', style: TextStyle(color: Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold)),
                                  )
                                ]
                              ],
                            ),
                            Text('৳ ${pkg.proposedReward.toStringAsFixed(0)}', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Route: ${pkg.routeInfo} • ${pkg.eta}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (pkg.isNearMiss)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                                child: Text('⚠️ Detour: +${pkg.distanceFromCorridor.toStringAsFixed(0)}m', style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              )
                            else
                              const Text('On Direct Highway Path', style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold)),

                            ElevatedButton(
                              onPressed: () {
                                if (pkg.isNearMiss) {
                                  _showDetourDialog(pkg);
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => DealChatScreen(package: pkg)),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
                              child: Text(pkg.isNearMiss ? 'PROPOSE OFFER' : 'DEAL ROOM', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
