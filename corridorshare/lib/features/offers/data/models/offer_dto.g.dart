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
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
