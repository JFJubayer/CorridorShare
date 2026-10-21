import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/features/offers/data/datasources/offer_datasource.dart';
import 'package:corridorshare/features/offers/data/models/offer_dto.dart';

class InMemoryOfferDataSource implements OfferDataSource {
  InMemoryOfferDataSource({List<OfferDto>? initialOffers, bool seed = false})
      : _offers = initialOffers != null
            ? List<OfferDto>.from(initialOffers)
            : (seed ? seedOffers() : <OfferDto>[]);

  final List<OfferDto> _offers;

  static List<OfferDto> seedOffers() {
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
        senderAccepted: true,
        travellerAccepted: false,
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
        senderAccepted: false,
        travellerAccepted: true,
        createdAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
        updatedAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
      ),
      OfferDto(
        id: 'offer-rafi',
        parcelId: 'parcel-documents',
        tripId: 'trip-rafi',
        senderId: 'sender-1',
        senderName: 'Tania',
        travellerId: 'traveller-rafi',
        travellerName: 'Rafi Mahmud',
        parcelTitle: 'Documents',
        fromDistrict: 'Dhaka',
        toDistrict: 'Mymensingh',
        price: 300.0,
        status: 'pendingSender',
        lastCounterBy: 'traveller-rafi',
        senderAccepted: false,
        travellerAccepted: true,
        travellerRating: 4.9,
        travellerTripsCount: 48,
        isTravellerVerified: true,
        noCarryTags: const <String>['No liquids', 'No fragile'],
        createdAt: now.subtract(const Duration(minutes: 45)).toIso8601String(),
        updatedAt: now.subtract(const Duration(minutes: 45)).toIso8601String(),
      ),
      OfferDto(
        id: 'offer-nila',
        parcelId: 'parcel-documents',
        tripId: 'trip-nila',
        senderId: 'sender-1',
        senderName: 'Tania',
        travellerId: 'traveller-nila',
        travellerName: 'Nila Akter',
        parcelTitle: 'Gift box',
        fromDistrict: 'Dhaka',
        toDistrict: 'Sylhet',
        price: 320.0,
        status: 'pendingSender',
        lastCounterBy: 'traveller-nila',
        senderAccepted: false,
        travellerAccepted: true,
        travellerRating: 4.7,
        travellerTripsCount: 31,
        isTravellerVerified: true,
        noCarryTags: const <String>['No electronics'],
        createdAt: now.subtract(const Duration(minutes: 30)).toIso8601String(),
        updatedAt: now.subtract(const Duration(minutes: 30)).toIso8601String(),
      ),
      OfferDto(
        id: 'offer-sabbir',
        parcelId: 'parcel-documents',
        tripId: 'trip-sabbir',
        senderId: 'sender-1',
        senderName: 'Tania',
        travellerId: 'traveller-sabbir',
        travellerName: 'Sabbir Hasan',
        parcelTitle: 'Phone case',
        fromDistrict: 'Dhaka',
        toDistrict: 'Sylhet',
        price: 280.0,
        status: 'pendingSender',
        lastCounterBy: 'traveller-sabbir',
        senderAccepted: false,
        travellerAccepted: true,
        travellerRating: 4.2,
        travellerTripsCount: 6,
        isTravellerVerified: false,
        noCarryTags: const <String>['No liquids'],
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
      ),
      OfferDto(
        id: 'offer-imran',
        parcelId: 'parcel-books',
        tripId: 'trip-imran',
        senderId: 'sender-1',
        senderName: 'Tania',
        travellerId: 'traveller-imran',
        travellerName: 'Imran Khan',
        parcelTitle: 'Books',
        fromDistrict: 'Dhaka',
        toDistrict: 'Mymensingh',
        price: 250.0,
        status: 'accepted',
        lastCounterBy: 'traveller-imran',
        senderAccepted: true,
        travellerAccepted: true,
        travellerRating: 4.8,
        travellerTripsCount: 22,
        isTravellerVerified: true,
        createdAt: now.subtract(const Duration(days: 3)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
      ),
      OfferDto(
        id: 'offer-support',
        parcelId: 'parcel-support',
        tripId: 'trip-support',
        senderId: 'sender-1',
        senderName: 'Tania',
        travellerId: 'corridorshare-support',
        travellerName: 'CorridorShare',
        parcelTitle: 'Support',
        fromDistrict: 'CorridorShare',
        toDistrict: '',
        price: 0.0,
        status: 'accepted',
        lastCounterBy: 'corridorshare-support',
        senderAccepted: true,
        travellerAccepted: true,
        travellerRating: 5.0,
        travellerTripsCount: 100,
        isTravellerVerified: true,
        createdAt: now.subtract(const Duration(days: 7)).toIso8601String(),
        updatedAt: now.subtract(const Duration(days: 7)).toIso8601String(),
      ),
    ];
  }

  @override
  Future<OfferDto> createOffer(OfferDto offer) async {
    final isSender = offer.senderId == offer.lastCounterBy;
    final item = offer.copyWith(
      senderAccepted: isSender,
      travellerAccepted: !isSender,
    );
    _offers.insert(0, item);
    return item;
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
      senderAccepted: isSender,
      travellerAccepted: !isSender,
      updatedAt: DateTime.now().toIso8601String(),
    );
    _offers[index] = updated;
    return updated;
  }

  @override
  Future<OfferDto> acceptOffer(
    String offerId, {
    String? acceptedByUserId,
  }) async {
    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) {
      throw const NotFoundFailure('Offer not found');
    }
    final current = _offers[index];

    bool senderAcc = current.senderAccepted;
    bool travellerAcc = current.travellerAccepted;

    if (acceptedByUserId != null && acceptedByUserId.isNotEmpty) {
      if (acceptedByUserId == current.senderId) {
        senderAcc = true;
      } else if (acceptedByUserId == current.travellerId) {
        travellerAcc = true;
      } else {
        if (!senderAcc) {
          senderAcc = true;
        } else {
          travellerAcc = true;
        }
      }
    } else {
      if (current.status == 'pendingSender') {
        senderAcc = true;
      } else if (current.status == 'pendingTraveller') {
        travellerAcc = true;
      } else {
        senderAcc = true;
        travellerAcc = true;
      }
    }

    final bothAccepted = senderAcc && travellerAcc;
    final nextStatus = bothAccepted
        ? 'accepted'
        : (senderAcc ? 'pendingTraveller' : 'pendingSender');

    final updated = current.copyWith(
      senderAccepted: senderAcc,
      travellerAccepted: travellerAcc,
      status: nextStatus,
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

  @override
  Future<List<OfferDto>> getOffersForParcel(String parcelId) async {
    // If parcel-documents or parcel-1 or documents title, return the 3 demo offers
    if (parcelId == 'parcel-documents' || parcelId == 'parcel-1') {
      final docs = _offers
          .where((o) =>
              o.status != 'rejected' &&
              (o.id == 'offer-rafi' ||
                  o.id == 'offer-nila' ||
                  o.id == 'offer-sabbir'))
          .toList();
      if (docs.isNotEmpty) return docs;
    }

    return _offers
        .where((o) => o.parcelId == parcelId && o.status != 'rejected')
        .toList();
  }
}
