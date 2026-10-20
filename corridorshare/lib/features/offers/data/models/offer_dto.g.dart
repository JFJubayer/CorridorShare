// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OfferDto _$OfferDtoFromJson(Map<String, dynamic> json) => _OfferDto(
  id: json['id'] as String,
  parcelId: json['parcelId'] as String,
  tripId: json['tripId'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  travellerId: json['travellerId'] as String,
  travellerName: json['travellerName'] as String,
  parcelTitle: json['parcelTitle'] as String,
  fromDistrict: json['fromDistrict'] as String,
  toDistrict: json['toDistrict'] as String,
  price: (json['price'] as num).toDouble(),
  status: json['status'] as String,
  lastCounterBy: json['lastCounterBy'] as String,
  travellerRating: (json['travellerRating'] as num?)?.toDouble() ?? 5.0,
  travellerTripsCount: (json['travellerTripsCount'] as num?)?.toInt() ?? 0,
  isTravellerVerified: json['isTravellerVerified'] as bool? ?? false,
  noCarryTags:
      (json['noCarryTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$OfferDtoToJson(_OfferDto instance) => <String, dynamic>{
  'id': instance.id,
  'parcelId': instance.parcelId,
  'tripId': instance.tripId,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'travellerId': instance.travellerId,
  'travellerName': instance.travellerName,
  'parcelTitle': instance.parcelTitle,
  'fromDistrict': instance.fromDistrict,
  'toDistrict': instance.toDistrict,
  'price': instance.price,
  'status': instance.status,
  'lastCounterBy': instance.lastCounterBy,
  'travellerRating': instance.travellerRating,
  'travellerTripsCount': instance.travellerTripsCount,
  'isTravellerVerified': instance.isTravellerVerified,
  'noCarryTags': instance.noCarryTags,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
