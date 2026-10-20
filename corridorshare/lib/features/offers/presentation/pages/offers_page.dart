import 'package:corridorshare/core/router/app_router.dart';
import 'package:corridorshare/core/theme/app_colors.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/presentation/providers/offer_providers.dart';
import 'package:corridorshare/features/offers/presentation/widgets/counter_offer_sheet.dart';
import 'package:corridorshare/features/offers/presentation/widgets/raise_budget_sheet.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_size.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OffersPage extends ConsumerStatefulWidget {
  const OffersPage({
    this.parcelId,
    this.parcel,
    super.key,
  });

  final String? parcelId;
  final Parcel? parcel;

  @override
  ConsumerState<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends ConsumerState<OffersPage> {
  Parcel? _parcel;
  bool _isLoadingParcel = false;

  @override
  void initState() {
    super.initState();
    if (widget.parcel != null) {
      _parcel = widget.parcel;
    } else {
      _loadParcel();
    }
  }

  Future<void> _loadParcel() async {
    final pid = widget.parcelId ?? 'parcel-1';
    setState(() => _isLoadingParcel = true);

    try {
      final res = await ref.read(parcelRepositoryProvider).getParcelById(pid);
      if (mounted) {
        switch (res) {
          case Ok<Parcel>(:final value):
            setState(() {
              _parcel = value;
              _isLoadingParcel = false;
            });
          case Err<Parcel>():
            setState(() {
              _parcel = _fallbackParcel(pid);
              _isLoadingParcel = false;
            });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _parcel = _fallbackParcel(pid);
          _isLoadingParcel = false;
        });
      }
    }
  }

  Parcel _fallbackParcel(String id) {
    return Parcel(
      id: id,
      senderId: 'sender-1',
      senderName: 'Tanvir Ahmed',
      title: 'Documents',
      fromDistrict: 'Dhaka',
      fromArea: 'Uttara',
      toDistrict: 'Mymensingh',
      toArea: 'Town Hall',
      weightKg: 1.2,
      size: ParcelSize.small,
      deadline: DateTime(2026, 10, 24, 9, 0),
      offeredPrice: 350,
      status: ParcelStatus.open,
      createdAt: DateTime(2026, 10, 18),
    );
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

  Future<void> _handleAcceptOffer(Offer offer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFF6F5EE),
        title: const Text('Accept offer?'),
        content: Text(
          'Accept offer of ৳${offer.price.toInt()} from ${offer.travellerName}?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16211A),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(offerActionControllerProvider.notifier)
        .acceptOffer(offer.id);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Offer from ${offer.travellerName} accepted!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleCounterOffer(Offer offer, Parcel parcel) async {
    final result = await CounterOfferSheet.show(
      context,
      offer: offer,
      budget: parcel.offeredPrice,
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Counter-offer sent successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleRaiseBudget(Parcel parcel) async {
    final newBudget = await RaiseBudgetSheet.show(context, parcel: parcel);
    if (newBudget != null && mounted) {
      setState(() {
        _parcel = parcel.copyWith(offeredPrice: newBudget);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget updated to ৳${newBudget.toInt()}!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingParcel && _parcel == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F5EE),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final parcel = _parcel ?? _fallbackParcel(widget.parcelId ?? 'parcel-1');
    final offersAsync = ref.watch(parcelOffersProvider(parcel.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EE),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: <Widget>[
            if (Navigator.of(context).canPop())
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    key: const Key('offersBackButton'),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.darkCharcoal,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),

            // Top Parcel Card
            _buildParcelSummaryCard(parcel),

            // Offers List or Empty State or Loading
            offersAsync.when(
              data: (offers) {
                if (offers.isEmpty) {
                  return _buildEmptyState(parcel);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // "3 OFFERS" Section Header aligned with card margin
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Text(
                        '${offers.length} OFFERS',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7E867B),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    // Offer Cards
                    ...offers.map((offer) => _buildOfferCard(offer, parcel)),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => _buildEmptyState(parcel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParcelSummaryCard(Parcel parcel) {
    final dateFormatted = DateFormat('EEE d MMM, h:mm a').format(parcel.deadline);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E6DB), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 3D Package Icon Container matching Screenshots
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEBE8DE),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 26,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(width: 14),

          // Content Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Top line: Title on left, Budget Badge on right (perfectly aligned horizontally)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '${parcel.title} · ${parcel.weightKg.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCharcoal,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBDDC37),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Budget ৳${parcel.offeredPrice.toInt()}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Corridor Route
                Text(
                  '${parcel.fromDistrict} → ${parcel.toDistrict}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF3D473E),
                  ),
                ),
                const SizedBox(height: 2),

                // Date & Time
                Text(
                  dateFormatted,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7E867B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Parcel parcel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 56, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Center Circle with Box Outline Icon
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: Color(0xFFEAE7DD),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 22),

          // Title
          const Text(
            'No offers yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkCharcoal,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),

          // Subtitle
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: const Text(
              "Travellers on this route can see your parcel. We'll notify you when someone makes an offer.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: Color(0xFF6E786B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons: Edit parcel & Raise budget
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FilledButton(
                key: const Key('editParcelButton'),
                onPressed: () {
                  context.push(AppRoutes.newParcel);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 46),
                  backgroundColor: const Color(0xFFEAE7DC),
                  foregroundColor: AppColors.darkCharcoal,
                  shape: const StadiumBorder(),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text(
                  'Edit parcel',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkCharcoal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                key: const Key('raiseBudgetButton'),
                onPressed: () => _handleRaiseBudget(parcel),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(120, 46),
                  backgroundColor: const Color(0xFF16211A),
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text(
                  'Raise budget',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(Offer offer, Parcel parcel) {
    final initials = _getInitials(offer.travellerName);

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
          // Header Row: Avatar on left, Name/Rating in middle, Price on right (top-aligned)
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

              // Name & Rating Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            offer.travellerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkCharcoal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (offer.isTravellerVerified) ...<Widget>[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Color(0xFF74A727),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '★ ${offer.travellerRating.toStringAsFixed(1)} · ${offer.travellerTripsCount} trips${offer.isTravellerVerified ? '' : ' · Unverified'}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6E786B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Price: Top-aligned opposite Traveller Name
              Text(
                '৳${offer.price.toInt()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkCharcoal,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),

          // Restriction Tags (No liquids, No fragile, No electronics)
          if (offer.noCarryTags.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: offer.noCarryTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE8E7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA84242),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Actions Row: Accept, Counter-offer, Chat (All 46px tall stadium buttons, perfectly aligned)
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              // Accept button
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 46,
                  child: FilledButton(
                    key: Key('acceptOfferButton_${offer.id}'),
                    onPressed: () => _handleAcceptOffer(offer),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16211A),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Counter-offer button
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 46,
                  child: FilledButton(
                    key: Key('counterOfferButton_${offer.id}'),
                    onPressed: () => _handleCounterOffer(offer, parcel),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E3D8),
                      foregroundColor: AppColors.darkCharcoal,
                      shape: const StadiumBorder(),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Counter-offer',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Chat icon button (identical 46x46 height and stadium shape)
              SizedBox(
                width: 46,
                height: 46,
                child: FilledButton(
                  key: Key('chatOfferButton_${offer.id}'),
                  onPressed: () {
                    context.push('${AppRoutes.chats}/${offer.id}');
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE5E3D8),
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
}
