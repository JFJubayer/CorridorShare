import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/presentation/providers/auth_providers.dart';
import 'package:corridorshare/features/matching/presentation/providers/matching_providers.dart';
import 'package:corridorshare/features/offers/presentation/widgets/make_offer_sheet.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/presentation/providers/parcel_providers.dart';
import 'package:corridorshare/features/parcels/presentation/widgets/parcel_card.dart';
import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/presentation/providers/trip_providers.dart';
import 'package:corridorshare/features/trips/presentation/widgets/trip_card.dart';
import 'package:corridorshare/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({
    this.tripId,
    this.parcelId,
    super.key,
  }) : assert(
          tripId != null || parcelId != null,
          'Either tripId or parcelId must be supplied',
        );

  final String? tripId;
  final String? parcelId;

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  Trip? _trip;
  Parcel? _parcel;
  List<Parcel>? _matchingParcels;
  List<Trip>? _matchingTrips;
  bool _isLoading = true;
  String? _errorMessage;

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
      if (widget.tripId != null) {
        final tripResult = await ref
            .read(tripRepositoryProvider)
            .getTripById(widget.tripId!);
        switch (tripResult) {
          case Ok<Trip>(:final value):
            _trip = value;
            final parcelsResult =
                await ref.read(findParcelsForTripUseCaseProvider)(value);
            switch (parcelsResult) {
              case Ok<List<Parcel>>(:final value):
                setState(() {
                  _matchingParcels = value;
                  _isLoading = false;
                });
              case Err<List<Parcel>>(:final failure):
                setState(() {
                  _errorMessage = failure.message;
                  _isLoading = false;
                });
            }
          case Err<Trip>(:final failure):
            setState(() {
              _errorMessage = failure.message;
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
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openOfferSheet({required Trip trip, required Parcel parcel}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => MakeOfferSheet(
        trip: trip,
        parcel: parcel,
        currentUserId: ref.read(currentUserProvider)?.id ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final title = widget.tripId != null
        ? '${l10n.matchingParcels} (${_trip?.fromDistrict ?? ""} → ${_trip?.toDistrict ?? ""})'
        : '${l10n.matchingTrips} (${_parcel?.fromDistrict ?? ""} → ${_parcel?.toDistrict ?? ""})';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: _buildBody(context, theme, l10n),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadMatches,
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }

    // Matching Parcels for a Trip
    if (widget.tripId != null && _trip != null) {
      if (_matchingParcels == null || _matchingParcels!.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  l10n.noMatchingParcels,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: _matchingParcels!.length,
        itemBuilder: (context, index) {
          final p = _matchingParcels![index];
          return Column(
            children: <Widget>[
              ParcelCard(parcel: p),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.tonalIcon(
                  onPressed: () => _openOfferSheet(trip: _trip!, parcel: p),
                  icon: const Icon(Icons.handshake),
                  label: Text('${l10n.makeOffer} (৳${p.offeredPrice.toStringAsFixed(0)})'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      );
    }

    // Matching Trips for a Parcel
    if (widget.parcelId != null && _parcel != null) {
      if (_matchingTrips == null || _matchingTrips!.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.flight_outlined, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  l10n.noMatchingTrips,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
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
              const SizedBox(height: 8),
            ],
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
