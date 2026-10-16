import 'package:corridorshare/features/parcels/domain/entities/parcel.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_size.dart';
import 'package:corridorshare/features/parcels/domain/entities/parcel_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'parcel_dto.freezed.dart';
part 'parcel_dto.g.dart';

@freezed
abstract class ParcelDto with _$ParcelDto {
  const factory ParcelDto({
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
    @Default('medium') String size,
    required String deadline,
    required double offeredPrice,
    @Default('open') String status,
    @Default(false) bool hasProhibitedItemsDeclaration,
    String? note,
    required String createdAt,
  }) = _ParcelDto;

  factory ParcelDto.fromJson(Map<String, dynamic> json) =>
      _$ParcelDtoFromJson(json);

  factory ParcelDto.fromDomain(Parcel parcel) => ParcelDto(
        id: parcel.id,
        senderId: parcel.senderId,
        senderName: parcel.senderName,
        title: parcel.title,
        fromDistrict: parcel.fromDistrict,
        fromArea: parcel.fromArea,
        toDistrict: parcel.toDistrict,
        toArea: parcel.toArea,
        categoryTags: parcel.categoryTags,
        weightKg: parcel.weightKg,
        size: parcel.size.name,
        deadline: parcel.deadline.toIso8601String(),
        offeredPrice: parcel.offeredPrice,
        status: parcel.status.name,
        hasProhibitedItemsDeclaration: parcel.hasProhibitedItemsDeclaration,
        note: parcel.note,
        createdAt: parcel.createdAt.toIso8601String(),
      );
}

extension ParcelDtoX on ParcelDto {
  Parcel toDomain() {
    return Parcel(
      id: id,
      senderId: senderId,
      senderName: senderName,
      title: title,
      fromDistrict: fromDistrict,
      fromArea: fromArea,
      toDistrict: toDistrict,
      toArea: toArea,
      categoryTags: categoryTags,
      weightKg: weightKg,
      size: ParcelSize.values.firstWhere(
        (e) => e.name == size,
        orElse: () => ParcelSize.medium,
      ),
      deadline: DateTime.parse(deadline),
      offeredPrice: offeredPrice,
      status: ParcelStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => ParcelStatus.open,
      ),
      hasProhibitedItemsDeclaration: hasProhibitedItemsDeclaration,
      note: note,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
