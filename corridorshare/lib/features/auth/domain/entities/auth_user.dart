import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';

/// Authenticated user, owned by the domain layer.
@freezed
abstract class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String phone,
    required String name,
    required bool verified,
    required double ratingAvg,
  }) = _AuthUser;
}
