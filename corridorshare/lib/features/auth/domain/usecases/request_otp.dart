import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';

/// Begin the phone OTP flow.
///
/// Validates the phone number through [PhoneNumber.tryParse] and forwards to
/// the repository. Returns a [ValidationFailure] for malformed input so
/// callers do not have to wrap parsing in try/catch.
class RequestOtp {
  const RequestOtp(this._repository);

  final AuthRepository _repository;

  Future<Result<String>> call(String phone) async {
    final PhoneNumber? parsed = PhoneNumber.tryParse(phone);
    if (parsed == null) {
      return const Err<String>(ValidationFailure('Invalid phone number'));
    }
    return _repository.requestOtp(parsed);
  }
}
