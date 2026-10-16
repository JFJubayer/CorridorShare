// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcel_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParcelDto _$ParcelDtoFromJson(Map<String, dynamic> json) => _ParcelDto(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  senderName: json['senderName'] as String,
  title: json['title'] as String,
  fromDistrict: json['fromDistrict'] as String,
  fromArea: json['fromArea'] as String,
  toDistrict: json['toDistrict'] as String,
  toArea: json['toArea'] as String,
  categoryTags:
      (json['categoryTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  weightKg: (json['weightKg'] as num).toDouble(),
  size: json['size'] as String? ?? 'medium',
  deadline: json['deadline'] as String,
  offeredPrice: (json['offeredPrice'] as num).toDouble(),
  status: json['status'] as String? ?? 'open',
  hasProhibitedItemsDeclaration:
      json['hasProhibitedItemsDeclaration'] as bool? ?? false,
  note: json['note'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ParcelDtoToJson(_ParcelDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'title': instance.title,
      'fromDistrict': instance.fromDistrict,
      'fromArea': instance.fromArea,
      'toDistrict': instance.toDistrict,
      'toArea': instance.toArea,
      'categoryTags': instance.categoryTags,
      'weightKg': instance.weightKg,
      'size': instance.size,
      'deadline': instance.deadline,
      'offeredPrice': instance.offeredPrice,
      'status': instance.status,
      'hasProhibitedItemsDeclaration': instance.hasProhibitedItemsDeclaration,
      'note': instance.note,
      'createdAt': instance.createdAt,
    };
