// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeliveryDto _$DeliveryDtoFromJson(Map<String, dynamic> json) => _DeliveryDto(
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
  agreedPrice: (json['agreedPrice'] as num).toDouble(),
  status: json['status'] as String,
  verificationPin: json['verificationPin'] as String,
  pickupPhotoUrl: json['pickupPhotoUrl'] as String?,
  pickupNotes: json['pickupNotes'] as String?,
  pickedUpAt: json['pickedUpAt'] as String?,
  deliveredAt: json['deliveredAt'] as String?,
  isDisputed: json['isDisputed'] as bool? ?? false,
  disputeReason: json['disputeReason'] as String?,
  disputedAt: json['disputedAt'] as String?,
  disputedBy: json['disputedBy'] as String?,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$DeliveryDtoToJson(_DeliveryDto instance) =>
    <String, dynamic>{
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
      'agreedPrice': instance.agreedPrice,
      'status': instance.status,
      'verificationPin': instance.verificationPin,
      'pickupPhotoUrl': instance.pickupPhotoUrl,
      'pickupNotes': instance.pickupNotes,
      'pickedUpAt': instance.pickedUpAt,
      'deliveredAt': instance.deliveredAt,
      'isDisputed': instance.isDisputed,
      'disputeReason': instance.disputeReason,
      'disputedAt': instance.disputedAt,
      'disputedBy': instance.disputedBy,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
