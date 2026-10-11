import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';

/// Domain-level contract for authentication.
///
/// Implementations live in `data/`. Use cases depend on this interface, not
/// on Firebase, so tests can substitute a fake.
abstract class AuthRepository {
  /// Begin phone OTP flow for [phone]. Returns a verification id that the
  /// caller passes back to [verifyOtp].
  Future<Result<String>> requestOtp(PhoneNumber phone);

  /// Verify a 6-digit [code] against a [verificationId] returned by
  /// [requestOtp]. On success the repository returns the signed-in user.
  Future<Result<AuthUser>> verifyOtp({
    required String verificationId,
    required String code,
  });

  /// Sign the current user out. Idempotent.
  Future<void> signOut();

  /// Stream of auth state changes. Emits `null` when signed out.
  Stream<AuthUser?> authStateChanges();
}
