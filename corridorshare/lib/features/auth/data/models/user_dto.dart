import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// Firestore-shaped DTO for a `users/{uid}` document. Lives in the data
/// layer; presentation converts to [AuthUser].
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    @Default('') String phone,
    @Default('') String email,
    @Default('') String name,
    @Default(false) bool verified,
    @Default(0.0) double ratingAvg,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, Object?> json) => _$UserDtoFromJson(json);
}