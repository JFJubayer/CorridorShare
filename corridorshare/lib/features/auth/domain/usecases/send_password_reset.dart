import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';

/// Send password reset email usecase.
class SendPasswordReset {
  const SendPasswordReset(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String email) async {
    final String trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmedEmail)) {
      return const Err<void>(ValidationFailure('Please enter a valid email address.'));
    }
    return _repository.sendPasswordResetEmail(trimmedEmail);
  }
}
