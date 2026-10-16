import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';
import 'package:corridorshare/features/auth/domain/usecases/send_password_reset.dart';
import 'package:corridorshare/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:corridorshare/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEmailAuthRepository implements AuthRepository {
  String? lastEmail;
  String? lastPassword;
  String? lastName;
  String? resetEmail;
  bool shouldFail = false;

  final AuthUser mockUser = const AuthUser(
    id: 'u-123',
    phone: '',
    email: 'user@example.com',
    name: 'Tanvir Ahmed',
    verified: true,
    ratingAvg: 5.0,
  );

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    if (shouldFail) {
      return const Err<AuthUser>(AuthFailure('Invalid credentials'));
    }
    return Ok<AuthUser>(mockUser);
  }

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    lastEmail = email;
    lastPassword = password;
    lastName = name;
    if (shouldFail) {
      return const Err<AuthUser>(AuthFailure('Email already in use'));
    }
    return Ok<AuthUser>(mockUser);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    resetEmail = email;
    if (shouldFail) {
      return const Err<void>(AuthFailure('User not found'));
    }
    return const Ok<void>(null);
  }

  @override
  Future<Result<String>> requestOtp(PhoneNumber phone) async =>
      const Ok<String>('vid-1');

  @override
  Future<Result<AuthUser>> verifyOtp({
    required String verificationId,
    required String code,
  }) async =>
      Ok<AuthUser>(mockUser);

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  AuthUser? get currentUser => null;
}

void main() {
  group('SignInWithEmail', () {
    test('rejects malformed email', () async {
      final _FakeEmailAuthRepository repo = _FakeEmailAuthRepository();
      final SignInWithEmail useCase = SignInWithEmail(repo);

      final Result<AuthUser> result =
          await useCase(email: 'invalid-email', password: 'password123');

      expect(result, isA<Err<AuthUser>>());
      expect((result as Err<AuthUser>).failure, isA<ValidationFailure>());
      expect(repo.lastEmail, isNull);
    });

    test('rejects short password (< 6 chars)', () async {
      final _FakeEmailAuthRepository repo = _FakeEmailAuthRepository();
      final SignInWithEmail useCase = SignInWithEmail(repo);

      final Result<AuthUser> result =
          await useCase(email: 'test@example.com', password: '123');

      expect(result, isA<Err<AuthUser>>());
      expect((result as Err<AuthUser>).failure, isA<ValidationFailure>());
      expect(repo.lastEmail, isNull);
    });

    test('forwards valid credentials to repository', () async {
      final _FakeEmailAuthRepository repo = _FakeEmailAuthRepository();
      final SignInWithEmail useCase = SignInWithEmail(repo);

      final Result<AuthUser> result =
          await useCase(email: 'test@example.com', password: 'secretpassword');

      expect(result, isA<Ok<AuthUser>>());
      expect(repo.lastEmail, 'test@example.com');
      expect(repo.lastPassword, 'secretpassword');
    });

    test('propagates repository error', () async {
      final _FakeEmailAuthRepository repo = _FakeEmailAuthRepository()..shouldFail = true;
      final SignInWithEmail useCase = SignInWithEmail(repo);

      final Result<AuthUser> result =
          await useCase(email: 'test@example.com', password: 'secretpassword');

      expect(result, isA<Err<AuthUser>>());
      expect((result as Err<AuthUser>).failure, isA<AuthFailure>());
    });
  });

  group('SignUpWithEmail', () {
    test('rejects malformed email', () async {
      final _FakeEmailAuthRepository repo = _FakeEmailAuthRepository();
      final SignUpWithEmail useCase = SignUpWithEmail(repo);

      final Result<AuthUser> result =
          await useCase(email: 'not-an-email', password: 'password123');

      expect(result, isA<Err<AuthUser>>());
    });

    test('creates account with name and valid credentials', () async {
      final _FakeEmailAuthRepository repo = _FakeEmailAuthRepository();
      final SignUpWithEmail useCase = SignUpWithEmail(repo);

      final Result<AuthUser> result = await useCase(
        email: 'newuser@example.com',
        password: 'securepassword',
        name: 'Tanvir Ahmed',
      );

      expect(result, isA<Ok<AuthUser>>());
      expect(repo.lastEmail, 'newuser@example.com');
      expect(repo.lastName, 'Tanvir Ahmed');
    });
  });

  group('SendPasswordReset', () {
    test('rejects empty or invalid email', () async {
      final _FakeEmailAuthRepository repo = _FakeEmailAuthRepository();
      final SendPasswordReset useCase = SendPasswordReset(repo);

      final Result<void> result = await useCase('bad-email');
      expect(result, isA<Err<void>>());
      expect(repo.resetEmail, isNull);
    });

    test('sends reset for valid email', () async {
      final _FakeEmailAuthRepository repo = _FakeEmailAuthRepository();
      final SendPasswordReset useCase = SendPasswordReset(repo);

      final Result<void> result = await useCase('user@example.com');
      expect(result, isA<Ok<void>>());
      expect(repo.resetEmail, 'user@example.com');
    });
  });
}
