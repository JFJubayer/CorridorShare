import 'package:corridorshare/features/trips/domain/entities/trip_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip.freezed.dart';

/// Represents a trip posted by a traveller. Pure Dart domain entity.
@freezed
abstract class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String travellerId,
    required String travellerName,
    required String fromDistrict,
    required String fromArea,
    required String toDistrict,
    required String toArea,
    required DateTime departureDate,
    required double capacityKg,
    @Default(0.0) double bookedKg,
    @Default(0) int matchingParcelsCount,
    @Default(<String>[]) List<String> noCarryTags,
    String? note,
    @Default(TripStatus.open) TripStatus status,
    required DateTime createdAt,
  }) = _Trip;
}
