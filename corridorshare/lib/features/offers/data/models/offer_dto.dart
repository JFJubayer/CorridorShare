import 'package:corridorshare/features/offers/domain/entities/offer.dart';
import 'package:corridorshare/features/offers/domain/entities/offer_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer_dto.freezed.dart';
part 'offer_dto.g.dart';

@freezed
abstract class OfferDto with _$OfferDto {
  const factory OfferDto({
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
    required String status,
    required String lastCounterBy,
    @Default(5.0) double travellerRating,
    @Default(0) int travellerTripsCount,
    @Default(false) bool isTravellerVerified,
    @Default(<String>[]) List<String> noCarryTags,
    required String createdAt,
    required String updatedAt,
  }) = _OfferDto;

  factory OfferDto.fromJson(Map<String, dynamic> json) =>
      _$OfferDtoFromJson(json);

  factory OfferDto.fromDomain(Offer offer) => OfferDto(
        id: offer.id,
        parcelId: offer.parcelId,
        tripId: offer.tripId,
        senderId: offer.senderId,
        senderName: offer.senderName,
        travellerId: offer.travellerId,
        travellerName: offer.travellerName,
        parcelTitle: offer.parcelTitle,
        fromDistrict: offer.fromDistrict,
        toDistrict: offer.toDistrict,
        price: offer.price,
        status: offer.status.name,
        lastCounterBy: offer.lastCounterBy,
        travellerRating: offer.travellerRating,
        travellerTripsCount: offer.travellerTripsCount,
        isTravellerVerified: offer.isTravellerVerified,
        noCarryTags: offer.noCarryTags,
        createdAt: offer.createdAt.toIso8601String(),
        updatedAt: offer.updatedAt.toIso8601String(),
      );
}

extension OfferDtoX on OfferDto {
  Offer toDomain() {
    return Offer(
      id: id,
      parcelId: parcelId,
      tripId: tripId,
      senderId: senderId,
      senderName: senderName,
      travellerId: travellerId,
      travellerName: travellerName,
      parcelTitle: parcelTitle,
      fromDistrict: fromDistrict,
      toDistrict: toDistrict,
      price: price,
      status: OfferStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => OfferStatus.pendingTraveller,
      ),
      lastCounterBy: lastCounterBy,
      travellerRating: travellerRating,
      travellerTripsCount: travellerTripsCount,
      isTravellerVerified: isTravellerVerified,
      noCarryTags: noCarryTags,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
