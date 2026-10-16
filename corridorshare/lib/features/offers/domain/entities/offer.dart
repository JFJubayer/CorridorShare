import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer.freezed.dart';

/// Represents a negotiated offer between a sender and traveller.
@freezed
abstract class Offer with _$Offer {
  const factory Offer({
    required String id,
    required String parcelId,
    required String tripId,
    required String senderId,
    required String senderName,
    required String travellerId,
    required String travellerName,
    required String parcelTitle,
    required String fromDistrict,
    required String toDistrict,
    required double price,
    required OfferStatus status,
    required String lastCounterBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Offer;
}
