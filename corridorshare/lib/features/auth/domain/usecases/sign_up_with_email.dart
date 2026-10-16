import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';

/// Sign up with email, password, and optional full name usecase.
class SignUpWithEmail {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
    String? name,
  }) async {
    final String trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmedEmail)) {
      return const Err<AuthUser>(ValidationFailure('Please enter a valid email address.'));
    }
    if (password.length < 6) {
      return const Err<AuthUser>(ValidationFailure('Password must be at least 6 characters.'));
    }
    return _repository.signUpWithEmail(
      email: trimmedEmail,
      password: password,
      name: name?.trim(),
    );
  }
}
