// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessageDto _$ChatMessageDtoFromJson(Map<String, dynamic> json) =>
    _ChatMessageDto(
      id: json['id'] as String,
      offerId: json['offerId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      text: json['text'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ChatMessageDtoToJson(_ChatMessageDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'offerId': instance.offerId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'text': instance.text,
      'createdAt': instance.createdAt,
    };
