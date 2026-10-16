import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';
import 'package:corridorshare/features/auth/domain/usecases/verify_otp.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements AuthRepository {
  String? receivedCode;
  AuthUser user = const AuthUser(
    id: 'u1',
    phone: '+8801712345678',
    name: 'Test',
    verified: false,
    ratingAvg: 0,
  );

  @override
  Future<Result<AuthUser>> verifyOtp({
    required String verificationId,
    required String code,
  }) async {
    receivedCode = code;
    return Ok<AuthUser>(user);
  }

  @override
  Future<Result<String>> requestOtp(PhoneNumber phone) async => const Ok<String>('v');

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      Ok<AuthUser>(user);

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async =>
      Ok<AuthUser>(user);

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async =>
      const Ok<void>(null);

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  AuthUser? get currentUser => user;
}

void main() {
  group('VerifyOtp', () {
    test('rejects non-numeric input', () async {
      final _FakeRepository repo = _FakeRepository();
      final VerifyOtp useCase = VerifyOtp(repo);

      final Result<AuthUser> result = await useCase(
        verificationId: 'v',
        code: '12ab56',
      );

      expect(result, isA<Err<AuthUser>>());
      expect((result as Err<AuthUser>).failure, isA<ValidationFailure>());
      expect(repo.receivedCode, isNull);
    });

    test('rejects codes of the wrong length', () async {
      final _FakeRepository repo = _FakeRepository();
      final VerifyOtp useCase = VerifyOtp(repo);

      final Result<AuthUser> result = await useCase(
        verificationId: 'v',
        code: '12345',
      );

      expect(result, isA<Err<AuthUser>>());
      expect(repo.receivedCode, isNull);
    });

    test('forwards a valid 6-digit code', () async {
      final _FakeRepository repo = _FakeRepository();
      final VerifyOtp useCase = VerifyOtp(repo);

      final Result<AuthUser> result = await useCase(
        verificationId: 'v',
        code: '  123456  ',
      );

      expect(result, isA<Ok<AuthUser>>());
      expect(repo.receivedCode, '123456');
    });
  });
}
