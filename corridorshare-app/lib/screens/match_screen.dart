import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../models/package_model.dart';
import '../models/trip_model.dart';
import '../providers/user_provider.dart';
import '../widgets/map_corridor.dart';
import '../widgets/ui.dart';
import 'deal_chat_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, this.initialTripId});

  final String? initialTripId;

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
    TripModel? preferred;
    final initialId = widget.initialTripId;
    if (initialId != null) {
      for (final trip in provider.trips) {
        if (trip.id == initialId) {
          preferred = trip;
          break;
        }
      }
    }
    final myTrips =
        provider.trips.where((t) => t.travelerId == provider.userId).toList();
    final fallback = preferred ??
        (myTrips.isNotEmpty
            ? myTrips.first
            : (provider.trips.isNotEmpty ? provider.trips.first : null));
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
      final matches =
          await context.read<UserProvider>().matchPackagesForTrip(trip.id);
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
    final offerController = TextEditingController(
        text: (pkg.proposedReward + 100).toStringAsFixed(0));
    String? error;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: const Text('Offer a detour price'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This pickup is ${pkg.distanceFromCorridor.toStringAsFixed(0)} m off your route. '
                  'Propose a price that covers the detour.',
                ),
                Gap.md,
                TextField(
                  controller: offerController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: ctx.tt.headlineSmall,
                  decoration: InputDecoration(
                    prefixText: '৳ ',
                    prefixStyle: ctx.tt.headlineSmall,
                    errorText: error,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final offer = double.tryParse(offerController.text);
                  if (offer == null || offer <= 0) {
                    setDialogState(() => error = 'Enter a positive amount.');
                    return;
                  }
                  final tripId = _selectedTrip?.id;
                  if (tripId == null) {
                    setDialogState(() => error = 'Select a trip first.');
                    return;
                  }
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DealChatScreen(
                        package: pkg,
                        tripId: tripId,
                        agreedReward: offer,
                      ),
                    ),
                  );
                },
                child: const Text('Send offer'),
              ),
            ],
          ),
        );
      },
    ).whenComplete(offerController.dispose);
  }

  void _openDeal(PackageModel pkg) {
    if (pkg.isNearMiss) {
      _showDetourDialog(pkg);
      return;
    }
    final tripId = _selectedTrip?.id;
    if (tripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a trip before opening a deal.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => DealChatScreen(package: pkg, tripId: tripId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final tripOptions = userProvider.trips;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching'),
        actions: [
          IconButton(
            tooltip: 'Refresh matches',
            onPressed: _loading ? null : _runMatch,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedTrip?.id,
              decoration: const InputDecoration(labelText: 'Your trip'),
              items: [
                for (final trip in tripOptions)
                  DropdownMenuItem(
                    value: trip.id,
                    child: Text(
                      '${trip.departureCity} → ${trip.destinationCity}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.32,
              child: MapCorridorWidget(
                packages: _matches,
                routePoints: _selectedTrip?.routePoints ?? const [],
                onPackageTap: (pkg) => setState(() => _selectedPackage = pkg),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _loading
                        ? 'Finding packages'
                        : '${_matches.length} ${_matches.length == 1 ? 'package' : 'packages'} on this route',
                    style: context.tt.titleMedium,
                  ),
                ),
                if (_loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: InlineNotice('$_error', tone: StatusTone.danger),
            ),
          Expanded(
            child: _loading && _matches.isEmpty
                ? const SkeletonList(rows: 3)
                : _matches.isEmpty
                    ? EmptyState(
                        icon: Icons.alt_route,
                        title: tripOptions.isEmpty
                            ? 'No trips yet'
                            : 'No packages matched',
                        message: tripOptions.isEmpty
                            ? 'Post a trip from Home, then come back to see packages along it.'
                            : (_error == null
                                ? 'Nothing is waiting on this route right now. Refresh or pick another trip.'
                                : 'Fix the error above and try again.'),
                        actionLabel: tripOptions.isEmpty ? null : 'Refresh',
                        onAction: tripOptions.isEmpty ? null : _runMatch,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _matches.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (ctx, idx) {
                          final pkg = _matches[idx];
                          final isSelected = _selectedPackage?.id == pkg.id;
                          return _MatchRow(
                            package: pkg,
                            selected: isSelected,
                            onTap: () => setState(() => _selectedPackage = pkg),
                            onOpen: () => _openDeal(pkg),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({
    required this.package,
    required this.selected,
    required this.onTap,
    required this.onOpen,
  });

  final PackageModel package;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected ? context.cs.surfaceContainerLow : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(package.itemDescription,
                        style: context.tt.titleSmall),
                  ),
                  Gap.md,
                  Text('৳ ${package.proposedReward.toStringAsFixed(0)}',
                      style: context.tt.titleMedium),
                ],
              ),
              Gap.xs,
              Text('${package.routeInfo} · ${package.etaLabel}',
                  style: context.tt.bodySmall),
              Gap.md,
              Row(
                children: [
                  Expanded(
                    child: package.isNearMiss
                        ? StatusText(
                            '${package.distanceFromCorridor.toStringAsFixed(0)} m detour',
                            tone: StatusTone.pending,
                            icon: Icons.alt_route,
                          )
                        : const StatusText('On your route',
                            tone: StatusTone.ok),
                  ),
                  OutlinedButton(
                    onPressed: onOpen,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: context.tt.labelMedium,
                    ),
                    child:
                        Text(package.isNearMiss ? 'Make offer' : 'Open deal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
