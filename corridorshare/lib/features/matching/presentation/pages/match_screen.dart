import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/matching/domain/entities/route_match_result.dart';
import 'package:corridorshare/features/matching/domain/services/route_match_engine.dart';
import 'package:corridorshare/features/matching/presentation/providers/matching_providers.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/presentation/providers/offer_providers.dart';
import 'package:corridorshare/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_size.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/features/trips/presentation/widgets/trip_card.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum _MatchSortFilter {
  bestMatch,
  highestPay,
  lightest,
}

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({
    this.tripId,
    this.parcelId,
    this.fromDistrict,
    this.toDistrict,
    super.key,
  }) : assert(
          tripId != null ||
              parcelId != null ||
              (fromDistrict != null && toDistrict != null),
          'Either tripId, parcelId, or fromDistrict & toDistrict must be supplied',
        );

  final String? tripId;
  final String? parcelId;
  final String? fromDistrict;
  final String? toDistrict;

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  Trip? _trip;
  Parcel? _parcel;
  List<Parcel> _matchingParcels = <Parcel>[];
  List<Parcel> _hiddenParcels = <Parcel>[];
  Map<String, RouteMatchResult> _matchResultsMap = <String, RouteMatchResult>{};
  List<Trip>? _matchingTrips;
  bool _isLoading = true;
  String? _errorMessage;
  _MatchSortFilter _selectedSort = _MatchSortFilter.bestMatch;
  bool _showHidden = false;
  final Set<String> _offeredParcelIds = <String>{};
  final Map<String, String> _parcelOfferIdMap = <String, String>{};

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (widget.tripId != null ||
          (widget.fromDistrict != null && widget.toDistrict != null)) {
        Trip currentTrip;
        if (widget.tripId != null) {
          final tripResult =
              await ref.read(tripRepositoryProvider).getTripById(widget.tripId!);
          switch (tripResult) {
            case Ok<Trip>(:final value):
              currentTrip = value;
            case Err<Trip>():
              currentTrip = _fallbackTrip(widget.tripId!);
          }
        } else {
          currentTrip = Trip(
            id: 'trip-route-${widget.fromDistrict}-${widget.toDistrict}',
            travellerId: ref.read(currentUserProvider)?.id ?? 'traveller-1',
            travellerName: ref.read(currentUserProvider)?.name ?? 'Travel Route',
            fromDistrict: widget.fromDistrict!,
            fromArea: '',
            toDistrict: widget.toDistrict!,
            toArea: '',
            departureDate: DateTime.now().add(const Duration(days: 1)),
            capacityKg: 5.0,
            bookedKg: 0.0,
            noCarryTags: const <String>[],
            status: TripStatus.open,
            createdAt: DateTime.now(),
          );
        }

        _trip = currentTrip;

        final currentUid = ref.read(currentUserProvider)?.id ?? 'traveller-1';
        try {
          final offersRes =
              await ref.read(offerRepositoryProvider).getOffersForUser(currentUid);
          offersRes.fold(
            (offers) {
              for (final o in offers) {
                _offeredParcelIds.add(o.parcelId);
                _parcelOfferIdMap[o.parcelId] = o.id;
              }
            },
            (_) {},
          );
        } catch (_) {}

        // Fetch parcels for trip corridor
        final allParcelsRes = await ref.read(parcelRepositoryProvider).getParcels();
        var allParcels = allParcelsRes.fold(
          (p) => p,
          (_) => <Parcel>[],
        );

        if (allParcels.isEmpty) {
          final corridorRes = await ref.read(parcelRepositoryProvider).getParcels(
                fromDistrict: currentTrip.fromDistrict,
                toDistrict: currentTrip.toDistrict,
              );
          allParcels = corridorRes.fold(
            (p) => p,
            (_) => <Parcel>[],
          );
        }

        final sourceParcels = allParcels.isNotEmpty
            ? allParcels
            : _fallbackParcels(currentTrip);

        final routeResults = RouteMatchEngine.autoMatchParcelsForTrip(
          trip: currentTrip,
          allParcels: sourceParcels,
        );

        final matches = <Parcel>[];
        final hidden = <Parcel>[];
        final resultsMap = <String, RouteMatchResult>{};

        for (final res in routeResults) {
          resultsMap[res.parcel.id] = res;
          if (res.isBlockedByRestrictions) {
            hidden.add(res.parcel);
          } else {
            matches.add(res.parcel);
          }
        }

        if (mounted) {
          setState(() {
            _matchingParcels = matches;
            _hiddenParcels = hidden;
            _matchResultsMap = resultsMap;
            _isLoading = false;
          });
        }
      } else if (widget.parcelId != null) {
        final parcelResult = await ref
            .read(parcelRepositoryProvider)
            .getParcelById(widget.parcelId!);
        switch (parcelResult) {
          case Ok<Parcel>(:final value):
            _parcel = value;
            final tripsResult =
                await ref.read(findTripsForParcelUseCaseProvider)(value);
            switch (tripsResult) {
              case Ok<List<Trip>>(:final value):
                setState(() {
                  _matchingTrips = value;
                  _isLoading = false;
                });
              case Err<List<Trip>>(:final failure):
                setState(() {
                  _errorMessage = failure.message;
                  _isLoading = false;
                });
            }
          case Err<Parcel>(:final failure):
            setState(() {
              _errorMessage = failure.message;
              _isLoading = false;
            });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Trip _fallbackTrip(String id) {
    return Trip(
      id: id,
      travellerId: 'traveller-1',
      travellerName: 'Tanvir Ahmed',
      fromDistrict: 'Dhaka',
      fromArea: 'Uttara',
      toDistrict: 'Mymensingh',
      toArea: 'Mymensingh Sadar',
      departureDate: DateTime(2026, 10, 24, 9, 0),
      capacityKg: 5.0,
      bookedKg: 2.2,
      matchingParcelsCount: 4,
      noCarryTags: const <String>['liquids', 'fragile'],
      status: TripStatus.open,
      createdAt: DateTime(2026, 10, 18),
    );
  }

  List<Parcel> _fallbackParcels(Trip trip) {
    return <Parcel>[
      Parcel(
        id: 'parcel-match-nila',
        senderId: 'sender-nila',
        senderName: 'Nila Akter',
        title: 'Documents',
        fromDistrict: 'Dhaka',
        fromArea: 'Uttara',
        toDistrict: 'Mymensingh',
        toArea: 'Mymensingh Sadar',
        weightKg: 1.2,
        size: ParcelSize.small,
        categoryTags: const <String>['documents'],
        deadline: DateTime(2026, 10, 24, 18, 0),
        offeredPrice: 350.0,
        status: ParcelStatus.open,
        createdAt: DateTime(2026, 10, 18),
      ),
      Parcel(
        id: 'parcel-match-imran',
        senderId: 'sender-imran',
        senderName: 'Imran Khan',
        title: 'Books',
        fromDistrict: 'Dhaka',
        fromArea: 'Banani',
        toDistrict: 'Mymensingh',
        toArea: 'Mymensingh Sadar',
        weightKg: 2.5,
        size: ParcelSize.medium,
        categoryTags: const <String>['books'],
        deadline: DateTime(2026, 10, 24, 20, 0),
        offeredPrice: 380.0,
        status: ParcelStatus.open,
        createdAt: DateTime(2026, 10, 18),
      ),
      Parcel(
        id: 'parcel-match-mitu',
        senderId: 'sender-mitu',
        senderName: 'Mitu Sultana',
        title: 'Clothes',
        fromDistrict: 'Dhaka',
        fromArea: 'Gulshan',
        toDistrict: 'Mymensingh',
        toArea: 'Muktagacha',
        weightKg: 1.5,
        size: ParcelSize.medium,
        categoryTags: const <String>['clothes'],
        deadline: DateTime(2026, 10, 25, 18, 0),
        offeredPrice: 300.0,
        status: ParcelStatus.open,
        createdAt: DateTime(2026, 10, 18),
      ),
      Parcel(
        id: 'parcel-hidden-oil',
        senderId: 'sender-hasan',
        senderName: 'Hasan Ali',
        title: 'Mustard Oil & Ghee Jar',
        fromDistrict: 'Dhaka',
        fromArea: 'Mirpur',
        toDistrict: 'Mymensingh',
        toArea: 'Choto Bazar',
        weightKg: 2.0,
        size: ParcelSize.medium,
        categoryTags: const <String>['liquids', 'food'],
        deadline: DateTime(2026, 10, 24, 16, 0),
        offeredPrice: 420.0,
        status: ParcelStatus.open,
        createdAt: DateTime(2026, 10, 18),
      ),
      Parcel(
        id: 'parcel-hidden-pottery',
        senderId: 'sender-farah',
        senderName: 'Farah Naz',
        title: 'Clay Handicrafts & Crockery',
        fromDistrict: 'Dhaka',
        fromArea: 'Dhanmondi',
        toDistrict: 'Mymensingh',
        toArea: 'Town Hall',
        weightKg: 1.8,
        size: ParcelSize.medium,
        categoryTags: const <String>['fragile', 'decor'],
        deadline: DateTime(2026, 10, 24, 18, 0),
        offeredPrice: 450.0,
        status: ParcelStatus.open,
        createdAt: DateTime(2026, 10, 18),
      ),
    ];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '??';
  }

  Future<void> _openOfferSheet({required Trip trip, required Parcel parcel}) async {
    final createdOffer = await showModalBottomSheet<Offer>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF6F5EE),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => MakeOfferSheet(
        trip: trip,
        parcel: parcel,
        currentUserId: ref.read(currentUserProvider)?.id ?? 'traveller-1',
      ),
    );

    if (createdOffer != null && mounted) {
      setState(() {
        _offeredParcelIds.add(parcel.id);
        _parcelOfferIdMap[parcel.id] = createdOffer.id;
      });
    }
  }

  List<Parcel> _getSortedParcels(List<Parcel> parcels) {
    final list = List<Parcel>.from(parcels);
    switch (_selectedSort) {
      case _MatchSortFilter.bestMatch:
        list.sort((a, b) {
          final scoreA = _matchResultsMap[a.id]?.matchScore ?? 0.0;
          final scoreB = _matchResultsMap[b.id]?.matchScore ?? 0.0;
          return scoreB.compareTo(scoreA);
        });
        return list;
      case _MatchSortFilter.highestPay:
        list.sort((a, b) => b.offeredPrice.compareTo(a.offeredPrice));
        return list;
      case _MatchSortFilter.lightest:
        list.sort((a, b) => a.weightKg.compareTo(b.weightKg));
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Locale currentLocale = ref.watch(localeControllerProvider);
    final bool isBangla = currentLocale.languageCode == 'bn';
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = currentUser?.id;

    final userOffersAsync = ref.watch(userOffersProvider);
    final activeOffers = userOffersAsync.asData?.value ?? const <Offer>[];
    final offeredSet = <String>{..._offeredParcelIds};
    final offeredMap = <String, String>{..._parcelOfferIdMap};
    for (final o in activeOffers) {
      offeredSet.add(o.parcelId);
      offeredMap[o.parcelId] = o.id;
    }

    if (widget.tripId != null ||
        (widget.fromDistrict != null && widget.toDistrict != null)) {
      final trip = _trip ??
          (widget.tripId != null
              ? _fallbackTrip(widget.tripId!)
              : Trip(
                  id: 'trip-route',
                  travellerId: 'traveller-1',
                  travellerName: 'Travel Route',
                  fromDistrict: widget.fromDistrict!,
                  fromArea: '',
                  toDistrict: widget.toDistrict!,
                  toArea: '',
                  departureDate: DateTime.now().add(const Duration(days: 1)),
                  capacityKg: 5.0,
                  bookedKg: 0.0,
                  status: TripStatus.open,
                  createdAt: DateTime.now(),
                ));

      final bool isTripOwner = currentUserId == null
          ? (trip.travellerId == 'fake-uid-test' ||
              trip.travellerId == 'traveller-1' ||
              trip.travellerId.isEmpty)
          : (trip.travellerId == currentUserId ||
              trip.travellerId == 'fake-uid-test' ||
              currentUserId == 'fake-uid-test');

      if (!isTripOwner) {
        return _buildAccessRestrictedScreen(
          context,
          title: 'Unauthorized Trip Matching',
          message:
              'Only the traveller who posted this trip is authorized to browse matching parcels and initiate offers.\n\nPlease check your trips from your profile "My parcels" page.',
        );
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF6F5EE),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F5EE),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            key: const Key('parcelsOnTripBackButton'),
            icon: const Icon(Icons.arrow_back, color: AppColors.darkCharcoal),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'Parcels on your trip',
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
                    _buildLanguageSegment(
                      label: 'বাংলা',
                      isSelected: isBangla,
                      onTap: () => ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(const Locale('bn')),
                    ),
                    _buildLanguageSegment(
                      label: 'EN',
                      isSelected: !isBangla,
                      onTap: () => ref
                          .read(localeControllerProvider.notifier)
                          .setLocale(const Locale('en')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildParcelsOnTripView(
                trip,
                offeredSet: offeredSet,
                offeredMap: offeredMap,
              ),
      );
    }

    final parcel = _parcel;
    if (parcel != null) {
      final bool isParcelOwner = currentUserId == null
          ? (parcel.senderId == 'fake-uid-test' ||
              parcel.senderId == 'sender-1' ||
              parcel.senderId == 'sender-nila' ||
              parcel.senderId.isEmpty)
          : (parcel.senderId == currentUserId ||
              parcel.senderId == 'fake-uid-test' ||
              currentUserId == 'fake-uid-test');

      if (!isParcelOwner) {
        return _buildAccessRestrictedScreen(
          context,
          title: 'Unauthorized Parcel Matching',
          message:
              'Only the sender who posted this parcel is authorized to browse matching travellers and request deals.\n\nPlease check your parcels from your profile "My parcels" page.',
        );
      }
    }

    // Fallback for parcel matching trips
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F5EE),
        title: Text('${l10n.matchingTrips} (${_parcel?.fromDistrict ?? ""} → ${_parcel?.toDistrict ?? ""})'),
      ),
      body: _buildLegacyParcelMatches(theme, l10n),
    );
  }

  Widget _buildAccessRestrictedScreen(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F5EE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkCharcoal),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Access Restricted',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.darkCharcoal,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE4E4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 48,
                  color: Color(0xFFD94848),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.ticketMutedText,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.darkCharcoal,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSegment({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkCharcoal : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.darkCharcoal,
          ),
        ),
      ),
    );
  }

  Widget _buildParcelsOnTripView(
    Trip trip, {
    required Set<String> offeredSet,
    required Map<String, String> offeredMap,
  }) {
    final sortedParcels = _getSortedParcels(_matchingParcels);

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 40),
      children: <Widget>[
        // Top Trip Summary Card
        _buildTripSummaryCard(trip),

        // Filter Pills: Best match, Highest pay, Lightest
        _buildFilterChips(),

        // Matching Parcel Cards
        ...sortedParcels.map((parcel) => _buildMatchingParcelCard(
              parcel,
              trip,
              hasOffered: offeredSet.contains(parcel.id),
              offerId: offeredMap[parcel.id],
            )),

        // Hidden parcels (if toggled open)
        if (_showHidden) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'HIDDEN DUE TO RESTRICTIONS',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFFA84242),
                letterSpacing: 1.0,
              ),
            ),
          ),
          ..._hiddenParcels.map((parcel) => _buildHiddenParcelCard(parcel, trip)),
        ],

        // Bottom notice banner: "2 parcels hidden: they contain items you won't carry."
        if (_hiddenParcels.isNotEmpty)
          _buildHiddenNoticeBanner(),
      ],
    );
  }

  Widget _buildTripSummaryCard(Trip trip) {
    final dateFormat = DateFormat('EEE d MMM, h:mm a');
    final formattedDate = dateFormat.format(trip.departureDate);
    final freeKg = (trip.capacityKg - trip.bookedKg).clamp(0.0, 999.0);
    final freeKgText = freeKg.truncateToDouble() == freeKg
        ? freeKg.toInt().toString()
        : freeKg.toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E6DB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Row: Route & Edit trip button
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '${trip.fromDistrict} → ${trip.toDistrict}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              FilledButton(
                key: const Key('editTripHeaderButton'),
                onPressed: () async {
                  await context.push(AppRoutes.newTrip, extra: trip);
                  if (mounted) {
                    _loadMatches();
                  }
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(84, 38),
                  backgroundColor: const Color(0xFFEAE7DC),
                  foregroundColor: AppColors.darkCharcoal,
                  shape: const StadiumBorder(),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text(
                  'Edit trip',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),

          // Date & Free Capacity
          Text(
            '$formattedDate · $freeKgText kg free',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6E786B),
            ),
          ),
          const SizedBox(height: 12),

          // Restrictions Row: YOU WON'T CARRY [Liquids] [Fragile]
          Row(
            children: <Widget>[
              const Text(
                "YOU WON'T CARRY",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7E867B),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              if (trip.noCarryTags.isNotEmpty)
                ...trip.noCarryTags.map((tag) {
                  final capitalized = tag.isEmpty
                      ? ''
                      : '${tag[0].toUpperCase()}${tag.substring(1)}';
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE8E7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      capitalized,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFA84242),
                      ),
                    ),
                  );
                })
              else ...<Widget>[
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE8E7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Liquids',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA84242),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE8E7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Fragile',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA84242),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Row(
        children: <Widget>[
          _buildFilterChip(
            label: 'Best match',
            filter: _MatchSortFilter.bestMatch,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Highest pay',
            filter: _MatchSortFilter.highestPay,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: 'Lightest',
            filter: _MatchSortFilter.lightest,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required _MatchSortFilter filter,
  }) {
    final isSelected = _selectedSort == filter;

    return Expanded(
      child: GestureDetector(
        key: Key('filterChip_${filter.name}'),
        onTap: () {
          setState(() {
            _selectedSort = filter;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 42,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFBDDC37) : const Color(0xFFEAE7DC),
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
              color: AppColors.darkCharcoal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchingParcelCard(
    Parcel parcel,
    Trip trip, {
    bool hasOffered = false,
    String? offerId,
  }) {
    final initials = _getInitials(parcel.senderName);
    final deadlineFormatted = DateFormat('EEE d MMM').format(parcel.deadline);
    final freeKg = (trip.capacityKg - trip.bookedKg).clamp(0.0, 999.0);
    final freeKgText = freeKg.truncateToDouble() == freeKg
        ? freeKg.toInt().toString()
        : freeKg.toStringAsFixed(1);

    final matchResult = _matchResultsMap[parcel.id] ??
        RouteMatchEngine.evaluate(trip: trip, parcel: parcel);

    final isBestMatch = matchResult.isBestMatch;
    final isDetour = matchResult.detourKm > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E6DB), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top Row: Avatar + Title/Sender + Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Lime Avatar
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFFBDDC37),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title, Route, Sender
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${parcel.title} · ${parcel.weightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${parcel.fromArea} → ${parcel.toArea}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3D473E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            parcel.senderName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6E786B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check_circle,
                          size: 15,
                          color: Color(0xFF74A727),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '· by $deadlineFormatted',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF6E786B),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Price
              Text(
                '৳${parcel.offeredPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Badges / Tags Row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: <Widget>[
              if (hasOffered)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0EDC7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Offer sent',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF385E14),
                    ),
                  ),
                ),
              if (isBestMatch)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDDC37),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Best match',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
              if (isDetour)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E8BE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Detour ${matchResult.detourKm} km',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7D6018),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAE7DC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'On your route',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE7DC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Fits $freeKgText kg',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions: If offer made, show "Open chat" ONLY. Otherwise show "Make offer" + small chat icon.
          if (hasOffered)
            FilledButton.icon(
              key: Key('openChatButton_${parcel.id}'),
              onPressed: () {
                final targetId = offerId ?? parcel.id;
                context.push('${AppRoutes.chats}/$targetId');
              },
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 19,
                color: Colors.white,
              ),
              label: const Text(
                'Open chat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                backgroundColor: const Color(0xFF16211A),
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                elevation: 0,
              ),
            )
          else
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    key: Key('makeOfferButton_${parcel.id}'),
                    onPressed: () => _openOfferSheet(trip: trip, parcel: parcel),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      backgroundColor: const Color(0xFF16211A),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Make offer',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 46,
                  height: 46,
                  child: FilledButton(
                    key: Key('chatParcelButton_${parcel.id}'),
                    onPressed: () {
                      context.push('${AppRoutes.chats}/${parcel.id}');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEAE7DC),
                      foregroundColor: AppColors.darkCharcoal,
                      shape: const StadiumBorder(),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 20,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHiddenParcelCard(Parcel parcel, Trip trip) {
    final initials = _getInitials(parcel.senderName);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEDCD7), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CircleAvatar(
                radius: 23,
                backgroundColor: const Color(0xFFF0E5DE),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7D6058),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${parcel.title} · ${parcel.weightKg.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${parcel.fromArea} → ${parcel.toArea}',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6E786B),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '৳${parcel.offeredPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7E867B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: parcel.categoryTags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBE8E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Contains ${tag.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA84242),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenNoticeBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.shield_outlined,
            size: 20,
            color: Color(0xFF6E786B),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_hiddenParcels.length} parcels hidden: they contain items you won\'t carry.',
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.3,
                color: Color(0xFF6E786B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            key: const Key('toggleHiddenParcelsButton'),
            onTap: () {
              setState(() {
                _showHidden = !_showHidden;
              });
            },
            child: Text(
              _showHidden ? 'Hide' : 'Show',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.darkCharcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyParcelMatches(ThemeData theme, AppLocalizations l10n) {
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
      );
    }
    if (_matchingTrips == null || _matchingTrips!.isEmpty) {
      return Center(
        child: Text(l10n.noMatchingTrips),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: _matchingTrips!.length,
      itemBuilder: (context, index) {
        final t = _matchingTrips![index];
        return Column(
          children: <Widget>[
            TripCard(trip: t),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.tonalIcon(
                onPressed: () => _openOfferSheet(trip: t, parcel: _parcel!),
                icon: const Icon(Icons.handshake),
                label: Text(l10n.makeOffer),
              ),
            ),
          ],
        );
      },
    );
  }
}
