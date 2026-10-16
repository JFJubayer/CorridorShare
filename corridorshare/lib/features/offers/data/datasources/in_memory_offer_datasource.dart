import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/features/offers/data/datasources/offer_datasource.dart';
import 'package:corridorshare/features/offers/data/models/offer_dto.dart';

class InMemoryOfferDataSource implements OfferDataSource {
  InMemoryOfferDataSource({List<OfferDto>? initialOffers, bool seed = false})
      : _offers = initialOffers != null
            ? List<OfferDto>.from(initialOffers)
            : (seed ? _seedOffers() : <OfferDto>[]);

  final List<OfferDto> _offers;

  static List<OfferDto> _seedOffers() {
    final now = DateTime.now();
    return <OfferDto>[
      OfferDto(
        id: 'offer-1',
        parcelId: 'parcel-1',
        tripId: 'trip-1',
        senderId: 'sender-1',
        senderName: 'Tanvir Ahmed',
        travellerId: 'traveller-1',
        travellerName: 'Rafiqul Islam',
        parcelTitle: 'Original Academic Transcripts',
        fromDistrict: 'Dhaka',
        toDistrict: 'Chattogram',
        price: 450.0,
        status: 'pendingTraveller',
        lastCounterBy: 'sender-1',
        createdAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
        updatedAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      OfferDto(
        id: 'offer-2',
        parcelId: 'parcel-1',
        tripId: 'trip-1',
        senderId: 'sender-1',
        senderName: 'Tanvir Ahmed',
        travellerId: 'traveller-1',
        travellerName: 'Rafiqul Islam',
        parcelTitle: 'Winter Garments Box',
        fromDistrict: 'Dhaka',
        toDistrict: 'Sylhet',
        price: 800.0,
        status: 'pendingSender',
        lastCounterBy: 'traveller-1',
        createdAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
        updatedAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
      ),
    ];
  }

  @override
  Future<OfferDto> createOffer(OfferDto offer) async {
    _offers.insert(0, offer);
    return offer;
  }

  @override
  Future<OfferDto> counterOffer({
    required String offerId,
    required double newPrice,
    required String counterByUserId,
  }) async {
    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) {
      throw const NotFoundFailure('Offer not found');
    }
    final current = _offers[index];
    final isSender = counterByUserId == current.senderId;
    final nextStatus = isSender ? 'pendingTraveller' : 'pendingSender';

    final updated = current.copyWith(
      price: newPrice,
      status: nextStatus,
      lastCounterBy: counterByUserId,
      updatedAt: DateTime.now().toIso8601String(),
    );
    _offers[index] = updated;
    return updated;
  }

  @override
  Future<OfferDto> acceptOffer(String offerId) async {
    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) {
      throw const NotFoundFailure('Offer not found');
    }
    final updated = _offers[index].copyWith(
      status: 'accepted',
      updatedAt: DateTime.now().toIso8601String(),
    );
    _offers[index] = updated;
    return updated;
  }

  @override
  Future<OfferDto> rejectOffer(String offerId) async {
    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) {
      throw const NotFoundFailure('Offer not found');
    }
    final updated = _offers[index].copyWith(
      status: 'rejected',
      updatedAt: DateTime.now().toIso8601String(),
    );
    _offers[index] = updated;
    return updated;
  }

  @override
  Future<OfferDto> getOfferById(String offerId) async {
    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) {
      throw const NotFoundFailure('Offer not found');
    }
    return _offers[index];
  }

  @override
  Future<List<OfferDto>> getOffersForUser(String userId) async {
    return _offers.where((o) {
      return o.senderId == userId || o.travellerId == userId;
    }).toList();
  }
}
