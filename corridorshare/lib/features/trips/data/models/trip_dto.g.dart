// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TripDto _$TripDtoFromJson(Map<String, dynamic> json) => _TripDto(
  id: json['id'] as String,
  travellerId: json['travellerId'] as String,
  travellerName: json['travellerName'] as String,
  fromDistrict: json['fromDistrict'] as String,
  fromArea: json['fromArea'] as String,
  toDistrict: json['toDistrict'] as String,
  toArea: json['toArea'] as String,
  departureDate: json['departureDate'] as String,
  capacityKg: (json['capacityKg'] as num).toDouble(),
  bookedKg: (json['bookedKg'] as num?)?.toDouble() ?? 0.0,
  matchingParcelsCount: (json['matchingParcelsCount'] as num?)?.toInt() ?? 0,
  noCarryTags:
      (json['noCarryTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  note: json['note'] as String?,
  status: json['status'] as String? ?? 'open',
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$TripDtoToJson(_TripDto instance) => <String, dynamic>{
  'id': instance.id,
  'travellerId': instance.travellerId,
  'travellerName': instance.travellerName,
  'fromDistrict': instance.fromDistrict,
  'fromArea': instance.fromArea,
  'toDistrict': instance.toDistrict,
  'toArea': instance.toArea,
  'departureDate': instance.departureDate,
  'capacityKg': instance.capacityKg,
  'bookedKg': instance.bookedKg,
  'matchingParcelsCount': instance.matchingParcelsCount,
  'noCarryTags': instance.noCarryTags,
  'note': instance.note,
  'status': instance.status,
  'createdAt': instance.createdAt,
};
