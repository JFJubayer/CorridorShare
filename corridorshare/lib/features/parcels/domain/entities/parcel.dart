import 'package:corridorshare/features/parcels/domain/entities/parcel_size.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'parcel.freezed.dart';

/// Represents a parcel posted by a sender. Pure Dart domain entity.
@freezed
abstract class Parcel with _$Parcel {
  const factory Parcel({
    required String id,
    required String senderId,
    required String senderName,
    required String title,
    required String fromDistrict,
    required String fromArea,
    required String toDistrict,
    required String toArea,
    @Default(<String>[]) List<String> categoryTags,
    required double weightKg,
    @Default(ParcelSize.medium) ParcelSize size,
    required DateTime deadline,
    required double offeredPrice,
    @Default(ParcelStatus.open) ParcelStatus status,
    @Default(false) bool hasProhibitedItemsDeclaration,
    String? note,
    required DateTime createdAt,
  }) = _Parcel;
}
