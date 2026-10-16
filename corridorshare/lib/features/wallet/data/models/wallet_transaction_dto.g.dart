// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletTransactionDto _$WalletTransactionDtoFromJson(
  Map<String, dynamic> json,
) => _WalletTransactionDto(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  referenceId: json['referenceId'] as String?,
  description: json['description'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$WalletTransactionDtoToJson(
  _WalletTransactionDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': instance.type,
  'amount': instance.amount,
  'referenceId': instance.referenceId,
  'description': instance.description,
  'createdAt': instance.createdAt,
};
