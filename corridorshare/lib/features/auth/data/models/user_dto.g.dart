// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['id'] as String,
  phone: json['phone'] as String? ?? '',
  email: json['email'] as String? ?? '',
  name: json['name'] as String? ?? '',
  verified: json['verified'] as bool? ?? false,
  ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'phone': instance.phone,
  'email': instance.email,
  'name': instance.name,
  'verified': instance.verified,
  'ratingAvg': instance.ratingAvg,
};
