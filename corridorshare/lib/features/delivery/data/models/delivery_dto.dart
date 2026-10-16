import 'package:corridorshare/features/delivery/domain/entities/delivery.dart';
import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_dto.freezed.dart';
part 'delivery_dto.g.dart';

@freezed
abstract class DeliveryDto with _$DeliveryDto {
  const factory DeliveryDto({
    required String id,
    required String parcelId,
    required String tripId,
    required String senderId,
    required String senderName,
    required String travellerId,
    required String travellerName,
    required String parcelTitle,
    required String fromDistrict,
    required String toDistrict,
    required double agreedPrice,
    required String status,
    required String verificationPin,
    String? pickupPhotoUrl,
    String? pickupNotes,
    String? pickedUpAt,
    String? deliveredAt,
    @Default(false) bool isDisputed,
    String? disputeReason,
    String? disputedAt,
    String? disputedBy,
    required String createdAt,
    required String updatedAt,
  }) = _DeliveryDto;

  factory DeliveryDto.fromJson(Map<String, dynamic> json) =>
      _$DeliveryDtoFromJson(json);

  factory DeliveryDto.fromDomain(Delivery domain) => DeliveryDto(
        id: domain.id,
        parcelId: domain.parcelId,
        tripId: domain.tripId,
        senderId: domain.senderId,
        senderName: domain.senderName,
        travellerId: domain.travellerId,
        travellerName: domain.travellerName,
        parcelTitle: domain.parcelTitle,
        fromDistrict: domain.fromDistrict,
        toDistrict: domain.toDistrict,
        agreedPrice: domain.agreedPrice,
        status: domain.status.name,
        verificationPin: domain.verificationPin,
        pickupPhotoUrl: domain.pickupPhotoUrl,
        pickupNotes: domain.pickupNotes,
        pickedUpAt: domain.pickedUpAt?.toIso8601String(),
        deliveredAt: domain.deliveredAt?.toIso8601String(),
        isDisputed: domain.isDisputed,
        disputeReason: domain.disputeReason,
        disputedAt: domain.disputedAt?.toIso8601String(),
        disputedBy: domain.disputedBy,
        createdAt: domain.createdAt.toIso8601String(),
        updatedAt: domain.updatedAt.toIso8601String(),
      );
}

extension DeliveryDtoX on DeliveryDto {
  Delivery toDomain() => Delivery(
        id: id,
        parcelId: parcelId,
        tripId: tripId,
        senderId: senderId,
        senderName: senderName,
        travellerId: travellerId,
        travellerName: travellerName,
        parcelTitle: parcelTitle,
        fromDistrict: fromDistrict,
        toDistrict: toDistrict,
        agreedPrice: agreedPrice,
        status: DeliveryStatus.values.firstWhere(
          (e) => e.name == status,
          orElse: () => DeliveryStatus.matched,
        ),
        verificationPin: verificationPin,
        pickupPhotoUrl: pickupPhotoUrl,
        pickupNotes: pickupNotes,
        pickedUpAt: pickedUpAt != null ? DateTime.parse(pickedUpAt!) : null,
        deliveredAt: deliveredAt != null ? DateTime.parse(deliveredAt!) : null,
        isDisputed: isDisputed,
        disputeReason: disputeReason,
        disputedAt: disputedAt != null ? DateTime.parse(disputedAt!) : null,
        disputedBy: disputedBy,
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );
}
