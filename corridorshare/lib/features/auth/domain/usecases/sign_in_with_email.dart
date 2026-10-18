import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';

/// Sign in with email or phone number and password usecase.
class SignInWithEmail {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call({
    required String email,
    required String password,
  }) async {
    final String trimmed = email.trim();
    final bool isEmail =
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(trimmed);
    final bool isPhone = PhoneNumber.tryParse(trimmed) != null ||
        RegExp(r'^(?:\+?88)?01[3-9]\d{8}$')
            .hasMatch(trimmed.replaceAll(RegExp(r'[\s-]'), ''));

    if (!isEmail && !isPhone) {
      return const Err<AuthUser>(
        ValidationFailure('Please enter a valid email address or phone number.'),
      );
    }
    if (password.length < 6) {
      return const Err<AuthUser>(
        ValidationFailure('Password must be at least 6 characters.'),
      );
    }
    return _repository.signInWithEmail(
      email: trimmed,
      password: password,
    );
  }
}
