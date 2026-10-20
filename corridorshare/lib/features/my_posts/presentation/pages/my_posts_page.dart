import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/parcels/presentation/widgets/carrying_now_card.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/features/trips/presentation/widgets/my_trip_item_card.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Locale currentLocale = ref.watch(localeControllerProvider);
    final bool isBangla = currentLocale.languageCode == 'bn';

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      appBar: AppBar(
        backgroundColor: AppColors.warmIvory,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkCharcoal),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'My parcels',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.darkCharcoal,
            letterSpacing: -0.5,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              height: 36,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E5DD),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _LanguageSegmentButton(
                    key: const Key('langBnButton'),
                    label: 'বাংলা',
                    isSelected: isBangla,
                    onTap: () {
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(const Locale('bn'));
                    },
                  ),
                  _LanguageSegmentButton(
                    key: const Key('langEnButton'),
                    label: 'EN',
                    isSelected: !isBangla,
                    onTap: () {
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(const Locale('en'));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Top Segmented Pill Selector (Sending | Carrying)
          Container(
            height: 52,
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEBE8DC),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    key: const Key('tabSending'),
                    onTap: () {
                      _tabController.animateTo(0);
                      setState(() {});
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: _tabController.index == 0
                            ? AppColors.limeAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.myPostsSending,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: _tabController.index == 0
                              ? FontWeight.w800
                              : FontWeight.w700,
                          color: _tabController.index == 0
                              ? AppColors.darkCharcoal
                              : AppColors.ticketMutedText,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    key: const Key('tabCarrying'),
                    onTap: () {
                      _tabController.animateTo(1);
                      setState(() {});
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: _tabController.index == 1
                            ? AppColors.limeAccent
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        l10n.myPostsCarrying,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: _tabController.index == 1
                              ? FontWeight.w800
                              : FontWeight.w700,
                          color: _tabController.index == 1
                              ? AppColors.darkCharcoal
                              : AppColors.ticketMutedText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                _SendingTab(l10n: l10n),
                _CarryingTab(l10n: l10n),
              ],
            ),
          ),
        ],
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
        final displayItems = _buildParcelCards(parcels);

        if (displayItems.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8E5DD),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 38,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No parcels sent yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Send a parcel across Bangladesh with\ntrusted, verified travellers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: AppColors.ticketMutedText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.push(AppRoutes.newParcel),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.limeAccent,
                      foregroundColor: AppColors.darkCharcoal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      l10n.postParcelTitle,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 40),
          itemCount: displayItems.length,
          itemBuilder: (context, index) {
            return _MyParcelItemCard(data: displayItems[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(err.toString())),
    );
  }

  List<_ParcelCardData> _buildParcelCards(List<Parcel> parcels) {
    final list = <_ParcelCardData>[];

    // Map real parcels if any
    for (final p in parcels) {
      final dateFormatted = DateFormat('EEE d MMM').format(p.deadline);
      list.add(
        _ParcelCardData(
          id: p.id,
          title: '${p.title} · ${p.weightKg.toStringAsFixed(1)} kg',
          routeAndDate: '${p.fromDistrict} → ${p.toDistrict} · $dateFormatted',
          detailText: p.status == ParcelStatus.open
              ? '3 offers so far'
              : (p.status == ParcelStatus.matched
                  ? 'Carried by verified peer'
                  : 'In delivery flow'),
          status: p.status,
          priceText: '৳${p.offeredPrice.toInt()}',
          parcel: p,
        ),
      );
    }

    return list;
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8E5DD),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 38,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No trips carried yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Post a trip you already plan to make and\ncarry parcels to earn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      color: AppColors.ticketMutedText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('postTripEmptyButton'),
                    onPressed: () => context.push(AppRoutes.newTrip),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.limeAccent,
                      foregroundColor: AppColors.darkCharcoal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                    ),
                    child: const Text(
                      'Post a trip',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 6, bottom: 40),
          children: <Widget>[
            // Section Header: MY TRIPS
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Text(
                'MY TRIPS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7E867B),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // User's Trip Cards
            ...trips.map((trip) => MyTripItemCard(trip: trip)),

            // Section Header: CARRYING NOW
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Text(
                'CARRYING NOW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7E867B),
                  letterSpacing: 1.2,
                ),
              ),
            ),

            // Active Carrying Card matching Screenshot 1
            const CarryingNowCard(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text(err.toString())),
    );
  }
}

class _ParcelCardData {
  const _ParcelCardData({
    required this.id,
    required this.title,
    required this.routeAndDate,
    required this.detailText,
    required this.status,
    required this.priceText,
    this.parcel,
  });

  final String id;
  final String title;
  final String routeAndDate;
  final String detailText;
  final ParcelStatus status;
  final String priceText;
  final Parcel? parcel;
}

class _MyParcelItemCard extends StatelessWidget {
  const _MyParcelItemCard({required this.data});

  final _ParcelCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Row: Title & Route on left, Badge & Price on right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkCharcoal,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.routeAndDate,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ticketMutedText,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.detailText,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ticketMutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  _buildStatusPill(data.status),
                  const SizedBox(height: 6),
                  Text(
                    data.priceText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contextual Action Buttons
          _buildActionButtons(context, data),
        ],
      ),
    );
  }

  Widget _buildStatusPill(ParcelStatus status) {
    final Color bgColor;
    final Color textColor;
    final String label;

    switch (status) {
      case ParcelStatus.open:
        bgColor = const Color(0xFFC8EA3B);
        textColor = AppColors.darkCharcoal;
        label = 'Open';
      case ParcelStatus.matched:
        bgColor = const Color(0xFFEBE1B5);
        textColor = AppColors.darkCharcoal;
        label = 'Matched';
      case ParcelStatus.inTransit:
        bgColor = const Color(0xFF16211A);
        textColor = Colors.white;
        label = 'In transit';
      case ParcelStatus.disputed:
        bgColor = const Color(0xFFFDE4E4);
        textColor = const Color(0xFFD94848);
        label = 'Disputed';
      case ParcelStatus.delivered:
        bgColor = const Color(0xFFC8EA3B);
        textColor = AppColors.darkCharcoal;
        label = 'Delivered';
      case ParcelStatus.cancelled:
        bgColor = const Color(0xFFEBE8DC);
        textColor = AppColors.ticketMutedText;
        label = 'Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, _ParcelCardData data) {
    switch (data.status) {
      case ParcelStatus.open:
        return Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: _ActionButton(
                label: 'Edit',
                bgColor: const Color(0xFFEFEEDA),
                textColor: AppColors.darkCharcoal,
                onPressed: () {
                  context.push(AppRoutes.newParcel);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _ActionButton(
                label: 'Cancel',
                bgColor: const Color(0xFFEFEEDA),
                textColor: const Color(0xFFD94848),
                onPressed: () => _confirmCancel(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: _ActionButton(
                label: 'View offers',
                bgColor: const Color(0xFF16211A),
                textColor: Colors.white,
                onPressed: () {
                  context.push(
                    '${AppRoutes.offers}?parcelId=${data.id}',
                    extra: data.parcel,
                  );
                },
              ),
            ),
          ],
        );

      case ParcelStatus.matched:
        return Row(
          children: <Widget>[
            Expanded(
              child: _ActionButton(
                label: 'Cancel',
                bgColor: const Color(0xFFEFEEDA),
                textColor: const Color(0xFFD94848),
                onPressed: () => _confirmCancel(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                label: 'Open deal',
                bgColor: const Color(0xFF16211A),
                textColor: Colors.white,
                onPressed: () {
                  context.push('${AppRoutes.deals}?role=sender');
                },
              ),
            ),
          ],
        );

      case ParcelStatus.inTransit:
        return SizedBox(
          width: double.infinity,
          child: _ActionButton(
            label: 'Open deal',
            bgColor: const Color(0xFF16211A),
            textColor: Colors.white,
            onPressed: () {
              context.push('${AppRoutes.deals}?role=sender');
            },
          ),
        );

      case ParcelStatus.disputed:
      case ParcelStatus.delivered:
      case ParcelStatus.cancelled:
        return SizedBox(
          width: double.infinity,
          child: _ActionButton(
            label: 'Open deal',
            bgColor: const Color(0xFFEFEEDA),
            textColor: AppColors.darkCharcoal,
            onPressed: () {
              context.push('${AppRoutes.deals}?role=sender');
            },
          ),
        );
    }
  }

  void _confirmCancel(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Parcel'),
          content: const Text(
            'Are you sure you want to cancel this parcel request?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD94848),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Parcel request cancelled.')),
                );
              },
              child: const Text('Cancel Request'),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onPressed,
  });

  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(21),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _LanguageSegmentButton extends StatelessWidget {
  const _LanguageSegmentButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCharcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.ticketMutedText,
          ),
        ),
      ),
    );
  }
}
