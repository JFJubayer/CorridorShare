import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/package_model.dart';
import '../models/trip_model.dart';
import '../providers/user_provider.dart';
import '../widgets/map_corridor.dart';
import 'deal_chat_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  PackageModel? _selectedPackage;
  TripModel? _selectedTrip;
  bool _loading = false;
  Object? _error;
  List<PackageModel> _matches = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<UserProvider>();
    final myTrips = provider.trips.where((t) => t.travelerId == provider.userId).toList();
    final fallback = myTrips.isNotEmpty ? myTrips.first : (provider.trips.isNotEmpty ? provider.trips.first : null);
    if (_selectedTrip == null && fallback != null) {
      _selectedTrip = fallback;
      WidgetsBinding.instance.addPostFrameCallback((_) => _runMatch());
    }
  }

  Future<void> _runMatch() async {
    final trip = _selectedTrip;
    if (trip == null) {
      setState(() {
        _matches = const [];
        _error = 'Post a trip before matching packages along your corridor.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final matches = await context.read<UserProvider>().matchPackagesForTrip(trip.id);
      if (!mounted) return;
      setState(() {
        _matches = matches;
        _loading = false;
      });
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _showDetourDialog(PackageModel pkg) {
    final offerController = TextEditingController(text: (pkg.proposedReward + 100).toStringAsFixed(0));

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          title: const Row(
            children: [
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
                'This package is ${pkg.distanceFromCorridor.toStringAsFixed(0)} meters off your corridor. Propose a detour compensation bonus:',
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
                final offer = double.tryParse(offerController.text);
                if (offer == null || offer <= 0) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Offer must be a positive amount.')));
                  return;
                }
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DealChatScreen(package: pkg)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
              child: const Text('SEND OFFER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ).whenComplete(offerController.dispose);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final tripOptions = userProvider.trips;

    return Scaffold(
      backgroundColor: const Color(0xFF051424),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          _selectedTrip == null
              ? 'Bangladesh corridor matching'
              : '${_selectedTrip!.departureCity} → ${_selectedTrip!.destinationCity}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _runMatch,
            icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedTrip?.id,
              dropdownColor: const Color(0xFF0F172A),
              decoration: const InputDecoration(
                labelText: 'Match against your trip (RPC)',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
              ),
              items: tripOptions
                  .map(
                    (trip) => DropdownMenuItem(
                      value: trip.id,
                      child: Text(
                        '${trip.departureCity} → ${trip.destinationCity}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                TripModel? trip;
                for (final candidate in tripOptions) {
                  if (candidate.id == id) {
                    trip = candidate;
                    break;
                  }
                }
                setState(() => _selectedTrip = trip);
                _runMatch();
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.36,
            child: MapCorridorWidget(
              packages: _matches,
              routePoints: _selectedTrip?.routePoints ?? const [],
              onPackageTap: (pkg) => setState(() => _selectedPackage = pkg),
            ),
          ),
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
                    Text(
                      _loading ? 'Matching…' : '${_matches.length} RPC Matches',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('match_packages_within_corridor', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('$_error', style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _matches.length,
              itemBuilder: (ctx, idx) {
                final pkg = _matches[idx];
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
                            Expanded(
                              child: Text(pkg.itemDescription, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                            Text('৳ ${pkg.proposedReward.toStringAsFixed(0)}', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Route: ${pkg.routeInfo} • ${pkg.etaLabel}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (pkg.isNearMiss)
                              Text('⚠️ Detour: +${pkg.distanceFromCorridor.toStringAsFixed(0)}m', style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold))
                            else
                              const Text('Within corridor buffer', style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold)),
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
