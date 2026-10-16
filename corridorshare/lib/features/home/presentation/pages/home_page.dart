import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/parcels/presentation/widgets/parcel_card.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/features/trips/presentation/widgets/trip_card.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedFeedIndex = 0; // 0: Trips, 1: Parcels

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedFeedIndex == 0) {
            await ref.read(tripsFeedProvider.notifier).refresh();
          } else {
            await ref.read(parcelsFeedProvider.notifier).refresh();
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: <Widget>[
            // Banner & Quick Actions Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.homeGreeting,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.homeSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Action Buttons
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _ActionButton(
                            key: const Key('postTripQuickAction'),
                            icon: Icons.directions_bus,
                            title: l10n.postTripTitle,
                            subtitle: l10n.quickActionTravelling,
                            color: theme.colorScheme.primaryContainer,
                            textColor: theme.colorScheme.onPrimaryContainer,
                            onTap: () => context.push(AppRoutes.newTrip),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            key: const Key('postParcelQuickAction'),
                            icon: Icons.local_shipping,
                            title: l10n.postParcelTitle,
                            subtitle: l10n.quickActionSending,
                            color: theme.colorScheme.secondaryContainer,
                            textColor: theme.colorScheme.onSecondaryContainer,
                            onTap: () => context.push(AppRoutes.newParcel),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Segmented Button
                    SegmentedButton<int>(
                      key: const Key('feedSegmentedButton'),
                      segments: <ButtonSegment<int>>[
                        ButtonSegment<int>(
                          value: 0,
                          icon: const Icon(Icons.people_outline),
                          label: Text(l10n.availableTrips),
                        ),
                        ButtonSegment<int>(
                          value: 1,
                          icon: const Icon(Icons.inventory_2_outlined),
                          label: Text(l10n.availableParcels),
                        ),
                      ],
                      selected: <int>{_selectedFeedIndex},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedFeedIndex = selection.first);
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Feed List
            if (_selectedFeedIndex == 0)
              _TripsFeedSliver(l10n: l10n)
            else
              _ParcelsFeedSliver(l10n: l10n),

            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.textColor,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 28, color: textColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TripsFeedSliver extends ConsumerWidget {
  const _TripsFeedSliver({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsFeedProvider);

    return tripsAsync.when(
      data: (trips) {
        if (trips.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.flight_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(l10n.noTripsFound),
                  ],
                ),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => TripCard(
              trip: trips[index],
              onTap: () => context.push('${AppRoutes.match}?tripId=${trips[index].id}'),
            ),
            childCount: trips.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(err.toString()),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => ref.read(tripsFeedProvider.notifier).refresh(),
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParcelsFeedSliver extends ConsumerWidget {
  const _ParcelsFeedSliver({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelsAsync = ref.watch(parcelsFeedProvider);

    return parcelsAsync.when(
      data: (parcels) {
        if (parcels.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.inventory_2_outlined,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(l10n.noParcelsFound),
                  ],
                ),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => ParcelCard(
              parcel: parcels[index],
              onTap: () => context.push('${AppRoutes.match}?parcelId=${parcels[index].id}'),
            ),
            childCount: parcels.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: <Widget>[
                Text(err.toString()),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(parcelsFeedProvider.notifier).refresh(),
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
