import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/data/models/user_dto.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';

/// Low-level contract that the Firebase implementation will satisfy.
abstract class AuthDataSource {
  Future<Result<String>> requestOtp(PhoneNumber phone);
  Future<Result<UserDto>> verifyOtp({
    required String verificationId,
    required String code,
  });
  Future<void> signOut();
  Stream<UserDto?> authStateChanges();
}
