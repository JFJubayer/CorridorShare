import 'package:corridorshare/features/delivery/domain/entities/delivery_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery.freezed.dart';

/// Represents a delivery agreement and verification tracking lifecycle.
@freezed
abstract class Delivery with _$Delivery {
  const factory Delivery({
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
    @Default(DeliveryStatus.matched) DeliveryStatus status,
    required String verificationPin,
    String? pickupPhotoUrl,
    String? pickupNotes,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    @Default(false) bool isDisputed,
    String? disputeReason,
    DateTime? disputedAt,
    String? disputedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Delivery;
}
