import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/parcels/presentation/widgets/parcel_card.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/features/trips/presentation/widgets/trip_card.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyPostsPage extends ConsumerStatefulWidget {
  const MyPostsPage({super.key});

  @override
  ConsumerState<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends ConsumerState<MyPostsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabMyPosts),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(text: l10n.myPostsSending),
            Tab(text: l10n.myPostsCarrying),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _SendingTab(l10n: l10n),
          _CarryingTab(l10n: l10n),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('myPostsFab'),
        onPressed: () {
          if (_tabController.index == 0) {
            context.push(AppRoutes.newParcel);
          } else {
            context.push(AppRoutes.newTrip);
          }
        },
        icon: Icon(_tabController.index == 0 ? Icons.add_box : Icons.add_road),
        label: Text(
          _tabController.index == 0 ? l10n.postParcelTitle : l10n.postTripTitle,
        ),
      ),
    );
  }
}

class _SendingTab extends ConsumerWidget {
  const _SendingTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myParcelsAsync = ref.watch(myParcelsProvider);

    return myParcelsAsync.when(
      data: (parcels) {
        if (parcels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  'You haven\'t posted any parcels yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => context.push(AppRoutes.newParcel),
                  child: Text(l10n.postParcelTitle),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: parcels.length,
          itemBuilder: (context, index) {
            final p = parcels[index];
            return ParcelCard(
              parcel: p,
              onTap: () {
                context.push('/deliveries/delivery-1');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(err.toString())),
    );
  }
}

class _CarryingTab extends ConsumerWidget {
  const _CarryingTab({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTripsAsync = ref.watch(myTripsProvider);

    return myTripsAsync.when(
      data: (trips) {
        if (trips.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(
                  Icons.luggage_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  'You haven\'t posted any trips yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => context.push(AppRoutes.newTrip),
                  child: Text(l10n.postTripTitle),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: trips.length,
          itemBuilder: (context, index) => TripCard(trip: trips[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(err.toString())),
    );
  }
}
