import 'package:corridorshare/features/trips/domain/entities/trip.dart';
import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_dto.freezed.dart';
part 'trip_dto.g.dart';

@freezed
abstract class TripDto with _$TripDto {
  const factory TripDto({
    required String id,
    required String travellerId,
    required String travellerName,
    required String fromDistrict,
    required String fromArea,
    required String toDistrict,
    required String toArea,
    required String departureDate,
    required double capacityKg,
    @Default(<String>[]) List<String> noCarryTags,
    String? note,
    @Default('open') String status,
    required String createdAt,
  }) = _TripDto;

  factory TripDto.fromJson(Map<String, dynamic> json) =>
      _$TripDtoFromJson(json);

  factory TripDto.fromDomain(Trip trip) => TripDto(
        id: trip.id,
        travellerId: trip.travellerId,
        travellerName: trip.travellerName,
        fromDistrict: trip.fromDistrict,
        fromArea: trip.fromArea,
        toDistrict: trip.toDistrict,
        toArea: trip.toArea,
        departureDate: trip.departureDate.toIso8601String(),
        capacityKg: trip.capacityKg,
        noCarryTags: trip.noCarryTags,
        note: trip.note,
        status: trip.status.name,
        createdAt: trip.createdAt.toIso8601String(),
      );
}

extension TripDtoX on TripDto {
  Trip toDomain() {
    return Trip(
      id: id,
      travellerId: travellerId,
      travellerName: travellerName,
      fromDistrict: fromDistrict,
      fromArea: fromArea,
      toDistrict: toDistrict,
      toArea: toArea,
      departureDate: DateTime.parse(departureDate),
      capacityKg: capacityKg,
      noCarryTags: noCarryTags,
      note: note,
      status: TripStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => TripStatus.open,
      ),
      createdAt: DateTime.parse(createdAt),
    );
  }
}
