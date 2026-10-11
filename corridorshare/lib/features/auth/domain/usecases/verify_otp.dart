import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';

/// Verify a phone OTP code and return the signed-in user.
///
/// The code is validated client-side for length and digit-only characters.
/// Firebase still re-verifies on the server.
class VerifyOtp {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String verificationId,
    required String code,
  }) async {
    final String trimmed = code.trim();
    if (trimmed.length != 6 || !RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return const Err<AuthUser>(ValidationFailure('OTP must be 6 digits'));
    }
    return _repository.verifyOtp(verificationId: verificationId, code: trimmed);
  }
}