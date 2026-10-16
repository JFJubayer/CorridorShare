import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';

/// Sign out usecase.
class SignOut {
  const SignOut(this._repository);

  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
