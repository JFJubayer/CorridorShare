import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction.dart';
import 'package:corridorshare/features/wallet/domain/entities/wallet_transaction_type.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_transaction_dto.freezed.dart';
part 'wallet_transaction_dto.g.dart';

@freezed
abstract class WalletTransactionDto with _$WalletTransactionDto {
  const factory WalletTransactionDto({
    required String id,
    required String userId,
    required String type,
    required double amount,
    String? referenceId,
    required String description,
    required String createdAt,
  }) = _WalletTransactionDto;

  factory WalletTransactionDto.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionDtoFromJson(json);

  factory WalletTransactionDto.fromDomain(WalletTransaction domain) =>
      WalletTransactionDto(
        id: domain.id,
        userId: domain.userId,
        type: domain.type.name,
        amount: domain.amount,
        referenceId: domain.referenceId,
        description: domain.description,
        createdAt: domain.createdAt.toIso8601String(),
      );
}

extension WalletTransactionDtoX on WalletTransactionDto {
  WalletTransaction toDomain() => WalletTransaction(
        id: id,
        userId: userId,
        type: WalletTransactionType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => WalletTransactionType.topUp,
        ),
        amount: amount,
        referenceId: referenceId,
        description: description,
        createdAt: DateTime.parse(createdAt),
      );
}
