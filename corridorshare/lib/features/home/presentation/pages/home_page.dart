import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/parcels/presentation/widgets/parcel_card.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/features/trips/presentation/widgets/trip_card.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum DateSortOption {
  none,
  earliestDate,
  latestDate,
  highestCapacityOrPrice,
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedFeedIndex = 0; // 0: Trips (Travellers), 1: Parcels
  DateTime? _selectedDate; // Filter by specific date
  DateSortOption _sortOption = DateSortOption.none;

  // Selected corridor filter
  String _selectedFromDistrict = 'Dhaka';
  String _selectedToDistrict = 'Chattogram';
  bool _filterByCorridor = false;

  late final AnimationController _fabController;
  late final Animation<double> _expandAnimation;
  late final Animation<double> _rotationAnimation;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _expandAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _fabController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  void _collapseFab() {
    if (_isFabExpanded) {
      setState(() {
        _isFabExpanded = false;
        _fabController.reverse();
      });
    }
  }

  void _showSortSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.warmIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Sort & Filter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 16),

                // Feed Type Toggle (Available Travellers vs Parcels to Carry)
                const Text(
                  'VIEW LISTINGS FOR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.ticketMutedText,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  key: const Key('feedSegmentedButton'),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.darkCharcoal;
                        }
                        return Colors.white;
                      },
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.white;
                        }
                        return AppColors.darkCharcoal;
                      },
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    side: WidgetStateProperty.all(
                      const BorderSide(color: AppColors.cardBorder, width: 1),
                    ),
                  ),
                  segments: <ButtonSegment<int>>[
                    ButtonSegment<int>(
                      value: 0,
                      icon: const Icon(Icons.people_outline, size: 18),
                      label: Text(
                        l10n.availableTrips,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      icon: const Icon(Icons.inventory_2_outlined, size: 18),
                      label: Text(
                        l10n.availableParcels,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  selected: <int>{_selectedFeedIndex},
                  onSelectionChanged: (selection) {
                    Navigator.pop(sheetContext);
                    setState(() => _selectedFeedIndex = selection.first);
                  },
                ),
                const SizedBox(height: 20),

                // Sort Options
                const Text(
                  'SORT BY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.ticketMutedText,
                  ),
                ),
                const SizedBox(height: 8),
                _SortRadioTile(
                  title: 'Date: Earliest First',
                  subtitle: 'Show upcoming departures or deadlines soonest',
                  isSelected: _sortOption == DateSortOption.earliestDate,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _sortOption = DateSortOption.earliestDate);
                  },
                ),
                _SortRadioTile(
                  title: 'Date: Latest First',
                  subtitle: 'Show departures or deadlines further away',
                  isSelected: _sortOption == DateSortOption.latestDate,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _sortOption = DateSortOption.latestDate);
                  },
                ),
                _SortRadioTile(
                  title: _selectedFeedIndex == 0
                      ? 'Capacity: Highest First'
                      : 'Reward: Highest First',
                  subtitle: _selectedFeedIndex == 0
                      ? 'Show travellers carrying largest capacity'
                      : 'Show parcels offering highest payment',
                  isSelected:
                      _sortOption == DateSortOption.highestCapacityOrPrice,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(
                      () =>
                          _sortOption = DateSortOption.highestCapacityOrPrice,
                    );
                  },
                ),
                _SortRadioTile(
                  title: 'Default / Reset',
                  subtitle: 'Recent postings order',
                  isSelected: _sortOption == DateSortOption.none,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _sortOption = DateSortOption.none);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCorridorPickerSheet(BuildContext context) {
    final corridors = <Map<String, String>>[
      {'from': 'Dhaka', 'to': 'Chattogram'},
      {'from': 'Chattogram', 'to': 'Dhaka'},
      {'from': 'Dhaka', 'to': 'Sylhet'},
      {'from': 'Sylhet', 'to': 'Dhaka'},
      {'from': 'Dhaka', 'to': 'Rajshahi'},
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.warmIvory,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Travel Corridor',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text(
                    'All Corridors (Show Everything)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: !_filterByCorridor
                      ? const Icon(Icons.check_circle,
                          color: AppColors.darkCharcoal)
                      : null,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    setState(() => _filterByCorridor = false);
                  },
                ),
                const Divider(),
                ...corridors.map((c) {
                  final isCurrent = _filterByCorridor &&
                      _selectedFromDistrict == c['from'] &&
                      _selectedToDistrict == c['to'];
                  return ListTile(
                    title: Text(
                      '${c['from']} ➔ ${c['to']}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: isCurrent
                        ? const Icon(Icons.check_circle,
                            color: AppColors.darkCharcoal)
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      setState(() {
                        _selectedFromDistrict = c['from']!;
                        _selectedToDistrict = c['to']!;
                        _filterByCorridor = true;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _toCode(String district) {
    if (district.isEmpty) return 'LOC';
    final cleaned = district.trim().toUpperCase();
    return cleaned.length >= 3 ? cleaned.substring(0, 3) : cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    // Prepare 14 upcoming dates
    final dates = List<DateTime>.generate(
      14,
      (index) => DateTime(now.year, now.month, now.day).add(
        Duration(days: index),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.warmIvory,
      // Floating Action Button on bottom-right (Vertical capsule speed dial as in attachment)
      floatingActionButton: AnimatedBuilder(
        animation: _fabController,
        builder: (context, child) {
          final isExpanded = _fabController.value > 0.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (isExpanded)
                FadeTransition(
                  opacity: _expandAnimation,
                  child: ScaleTransition(
                    scale: _expandAnimation,
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                          // Vertical White Capsule matching attachment
                          Container(
                            width: 56,
                            height: 114,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                              border: Border.all(
                                color: AppColors.cardBorder,
                                width: 1.2,
                              ),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x18000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),

                          // Items inside capsule + Floating labels to the left
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              const SizedBox(height: 8),
                              _SpeedDialItem(
                                key: const Key('postTripQuickAction'),
                                label: l10n.postTripTitle,
                                icon: Icons.flight_takeoff,
                                iconBg: AppColors.limeAccent,
                                iconColor: AppColors.darkCharcoal,
                                onTap: () {
                                  _collapseFab();
                                  context.push(AppRoutes.newTrip);
                                },
                              ),
                              const SizedBox(height: 6),
                              _SpeedDialItem(
                                key: const Key('postParcelQuickAction'),
                                label: l10n.postParcelTitle,
                                icon: Icons.inventory_2_outlined,
                                iconBg: AppColors.darkCharcoal,
                                iconColor: Colors.white,
                                onTap: () {
                                  _collapseFab();
                                  context.push(AppRoutes.newParcel);
                                },
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Circular Button: Charcoal circle with lime animated + to X
              GestureDetector(
                key: const Key('homeFabPlus'),
                onTap: _toggleFab,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.darkCharcoal,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0x35122017),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: const Icon(
                        Icons.add,
                        color: AppColors.limeAccent,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      body: Stack(
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
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
              // Top Bar with Brand & Segment Toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    children: <Widget>[
                      // Top Row: App Brand & Quick Action Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          // Circle button with back / app icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.near_me,
                                size: 20,
                                color: AppColors.darkCharcoal,
                              ),
                            ),
                          ),

                          // Brand Name
                          Text(
                            l10n.appTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                              color: AppColors.darkCharcoal,
                            ),
                          ),

                          // Profile / Language button
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.person_outline,
                                size: 20,
                                color: AppColors.darkCharcoal,
                              ),
                              onPressed: () => context.go(AppRoutes.profile),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Route / Corridor Banner (As in attachment)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.bannerBg,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            // Route: Origin -> Flight Circle -> Destination
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // Origin
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        _toCode(_selectedFromDistrict),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.darkCharcoal,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        _selectedFromDistrict,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.ticketMutedText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),

                                // Flight route line with plane badge
                                Expanded(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                              children: List.generate(
                                                5,
                                                (i) => Container(
                                                  width: 3,
                                                  height: 3,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        AppColors.darkCharcoal,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.darkCharcoal,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.flight,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceEvenly,
                                              children: List.generate(
                                                5,
                                                (i) => Container(
                                                  width: 3,
                                                  height: 3,
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        AppColors.darkCharcoal,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Destination
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        _toCode(_selectedToDistrict),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.darkCharcoal,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        _selectedToDistrict,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.ticketMutedText,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Action Pills under route: Searching & Change
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkCharcoal,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          _filterByCorridor
                                              ? 'Active Corridor'
                                              : 'All Routes',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.blur_circular,
                                          size: 14,
                                          color: AppColors.limeAccent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: InkWell(
                                    onTap: () =>
                                        _showCorridorPickerSheet(context),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppColors.cardBorder,
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Change',
                                            style: TextStyle(
                                              color: AppColors.darkCharcoal,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Icon(
                                            Icons.swap_horiz,
                                            size: 16,
                                            color: AppColors.darkCharcoal,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status & Summary Pill Row (As in attachment: Today, Month, Counter)
                      Row(
                        children: <Widget>[
                          // Today pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: const Row(
                              children: <Widget>[
                                Icon(Icons.calendar_today,
                                    size: 13, color: AppColors.darkCharcoal),
                                SizedBox(width: 6),
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Month, Year pill
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: AppColors.cardBorder),
                              ),
                              child: Center(
                                child: Text(
                                  DateFormat('MMMM, yyyy').format(now),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkCharcoal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Counter / Active Pill
                          Consumer(
                            builder: (context, ref, _) {
                              final count = _selectedFeedIndex == 0
                                  ? ref
                                          .watch(tripsFeedProvider)
                                          .valueOrNull
                                          ?.length ??
                                      0
                                  : ref
                                          .watch(parcelsFeedProvider)
                                          .valueOrNull
                                          ?.length ??
                                      0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    const Icon(Icons.hub_outlined,
                                        size: 13,
                                        color: AppColors.darkCharcoal),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$count Active',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkCharcoal,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Horizontal Date Selector Strip (As in attachment)
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: dates.length + 1,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isAll = _selectedDate == null;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedDate = null),
                                child: Container(
                                  width: 48,
                                  decoration: BoxDecoration(
                                    color: isAll
                                        ? AppColors.limeAccent
                                        : AppColors.pillInactive,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isAll
                                          ? AppColors.limeAccent
                                          : AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        'ALL',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: isAll
                                              ? AppColors.darkCharcoal
                                              : AppColors.ticketMutedText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Icon(
                                        Icons.apps,
                                        size: 16,
                                        color: isAll
                                            ? AppColors.darkCharcoal
                                            : AppColors.ticketMutedText,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final date = dates[index - 1];
                            final isSelected = _selectedDate != null &&
                                _selectedDate!.year == date.year &&
                                _selectedDate!.month == date.month &&
                                _selectedDate!.day == date.day;

                            final dayLetter =
                                DateFormat('E').format(date).substring(0, 1);
                            final dayNumber = DateFormat('d').format(date);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedDate = null;
                                  } else {
                                    _selectedDate = date;
                                  }
                                });
                              },
                              child: Container(
                                width: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.limeAccent
                                      : AppColors.pillInactive,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.limeAccent
                                        : AppColors.cardBorder,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      dayLetter,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.darkCharcoal
                                            : AppColors.ticketMutedText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dayNumber,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: isSelected
                                            ? AppColors.darkCharcoal
                                            : AppColors.darkCharcoal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Results count & Sort/Filter Header (As in attachment: "14 Tickets found")
                      Consumer(
                        builder: (context, ref, _) {
                          final count = _selectedFeedIndex == 0
                              ? ref
                                      .watch(tripsFeedProvider)
                                      .valueOrNull
                                      ?.length ??
                                  0
                              : ref
                                      .watch(parcelsFeedProvider)
                                      .valueOrNull
                                      ?.length ??
                                  0;
                          final title = _selectedFeedIndex == 0
                              ? '$count Travellers found'
                              : '$count Parcels found';

                          return Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.darkCharcoal,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              // Circular Filter/Sort Button with red indicator dot
                              GestureDetector(
                                onTap: () => _showSortSheet(context, l10n),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: <Widget>[
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.cardBorder),
                                        boxShadow: const <BoxShadow>[
                                          BoxShadow(
                                            color: Color(0x0A000000),
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.tune_rounded,
                                        size: 20,
                                        color: AppColors.darkCharcoal,
                                      ),
                                    ),
                                    // Red indicator dot
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: _sortOption !=
                                                  DateSortOption.none
                                              ? Colors.green
                                              : const Color(0xFFE53935),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Feeds with filter & sort applied
              if (_selectedFeedIndex == 0)
                _TripsFeedSliver(
                  l10n: l10n,
                  selectedDate: _selectedDate,
                  sortOption: _sortOption,
                  fromDistrict:
                      _filterByCorridor ? _selectedFromDistrict : null,
                  toDistrict: _filterByCorridor ? _selectedToDistrict : null,
                )
              else
                _ParcelsFeedSliver(
                  l10n: l10n,
                  selectedDate: _selectedDate,
                  sortOption: _sortOption,
                  fromDistrict:
                      _filterByCorridor ? _selectedFromDistrict : null,
                  toDistrict: _filterByCorridor ? _selectedToDistrict : null,
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
      if (_isFabExpanded)
        Positioned.fill(
          child: GestureDetector(
            onTap: _collapseFab,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
            ),
          ),
        ),
    ],
  ),
);
}
}

class _TripsFeedSliver extends ConsumerWidget {
  const _TripsFeedSliver({
    required this.l10n,
    required this.selectedDate,
    required this.sortOption,
    required this.fromDistrict,
    required this.toDistrict,
  });

  final AppLocalizations l10n;
  final DateTime? selectedDate;
  final DateSortOption sortOption;
  final String? fromDistrict;
  final String? toDistrict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsFeedProvider);

    return tripsAsync.when(
      data: (allTrips) {
        var trips = List<Trip>.from(allTrips);

        // Filter by Corridor
        if (fromDistrict != null && fromDistrict!.isNotEmpty) {
          trips = trips
              .where((t) =>
                  t.fromDistrict.toLowerCase() ==
                  fromDistrict!.toLowerCase())
              .toList();
        }
        if (toDistrict != null && toDistrict!.isNotEmpty) {
          trips = trips
              .where((t) =>
                  t.toDistrict.toLowerCase() == toDistrict!.toLowerCase())
              .toList();
        }

        // Filter by Date
        if (selectedDate != null) {
          trips = trips.where((t) {
            return t.departureDate.year == selectedDate!.year &&
                t.departureDate.month == selectedDate!.month &&
                t.departureDate.day == selectedDate!.day;
          }).toList();
        }

        // Sort by Date or Capacity
        switch (sortOption) {
          case DateSortOption.earliestDate:
            trips.sort((a, b) => a.departureDate.compareTo(b.departureDate));
            break;
          case DateSortOption.latestDate:
            trips.sort((a, b) => b.departureDate.compareTo(a.departureDate));
            break;
          case DateSortOption.highestCapacityOrPrice:
            trips.sort((a, b) => b.capacityKg.compareTo(a.capacityKg));
            break;
          case DateSortOption.none:
            break;
        }

        if (trips.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.flight_outlined,
                      size: 48,
                      color: AppColors.ticketMutedText,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noTripsFound,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
              onTap: () =>
                  context.push('${AppRoutes.match}?tripId=${trips[index].id}'),
            ),
            childCount: trips.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.darkCharcoal),
          ),
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
                      ref.read(tripsFeedProvider.notifier).refresh(),
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
  const _ParcelsFeedSliver({
    required this.l10n,
    required this.selectedDate,
    required this.sortOption,
    required this.fromDistrict,
    required this.toDistrict,
  });

  final AppLocalizations l10n;
  final DateTime? selectedDate;
  final DateSortOption sortOption;
  final String? fromDistrict;
  final String? toDistrict;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parcelsAsync = ref.watch(parcelsFeedProvider);

    return parcelsAsync.when(
      data: (allParcels) {
        var parcels = List<Parcel>.from(allParcels);

        // Filter by Corridor
        if (fromDistrict != null && fromDistrict!.isNotEmpty) {
          parcels = parcels
              .where((p) =>
                  p.fromDistrict.toLowerCase() ==
                  fromDistrict!.toLowerCase())
              .toList();
        }
        if (toDistrict != null && toDistrict!.isNotEmpty) {
          parcels = parcels
              .where((p) =>
                  p.toDistrict.toLowerCase() == toDistrict!.toLowerCase())
              .toList();
        }

        // Filter by Date
        if (selectedDate != null) {
          parcels = parcels.where((p) {
            return p.deadline.year == selectedDate!.year &&
                p.deadline.month == selectedDate!.month &&
                p.deadline.day == selectedDate!.day;
          }).toList();
        }

        // Sort by Date or Price
        switch (sortOption) {
          case DateSortOption.earliestDate:
            parcels.sort((a, b) => a.deadline.compareTo(b.deadline));
            break;
          case DateSortOption.latestDate:
            parcels.sort((a, b) => b.deadline.compareTo(a.deadline));
            break;
          case DateSortOption.highestCapacityOrPrice:
            parcels.sort((a, b) => b.offeredPrice.compareTo(a.offeredPrice));
            break;
          case DateSortOption.none:
            break;
        }

        if (parcels.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: AppColors.ticketMutedText,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noParcelsFound,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkCharcoal,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
              onTap: () => context
                  .push('${AppRoutes.match}?parcelId=${parcels[index].id}'),
            ),
            childCount: parcels.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.darkCharcoal),
          ),
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

class _SortRadioTile extends StatelessWidget {
  const _SortRadioTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: AppColors.darkCharcoal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.ticketMutedText),
      ),
      trailing: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.darkCharcoal : AppColors.cardBorder,
            width: isSelected ? 6 : 1.5,
          ),
        ),
      ),
    );
  }
}

class _SpeedDialItem extends StatelessWidget {
  const _SpeedDialItem({
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Floating Label to the left
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.darkCharcoal,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Icon button inside the vertical white capsule (Theme consistent)
          SizedBox(
            width: 56,
            height: 48,
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
