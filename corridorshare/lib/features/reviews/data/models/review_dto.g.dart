// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) => _ReviewDto(
  id: json['id'] as String,
  deliveryId: json['deliveryId'] as String,
  reviewerId: json['reviewerId'] as String,
  reviewerName: json['reviewerName'] as String,
  targetUserId: json['targetUserId'] as String,
  targetUserName: json['targetUserName'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ReviewDtoToJson(_ReviewDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deliveryId': instance.deliveryId,
      'reviewerId': instance.reviewerId,
      'reviewerName': instance.reviewerName,
      'targetUserId': instance.targetUserId,
      'targetUserName': instance.targetUserName,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt,
    };
