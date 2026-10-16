import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';
import 'package:corridorshare/features/auth/domain/usecases/request_otp.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements AuthRepository {
  String? lastPhoneE164;
  String? nextError;
  String verificationId = 'vid-1';

  @override
  Future<Result<String>> requestOtp(PhoneNumber phone) async {
    lastPhoneE164 = phone.e164;
    if (nextError != null) {
      return Err<String>(ServerFailure(nextError!));
    }
    return Ok<String>(verificationId);
  }

  @override
  Future<Result<AuthUser>> verifyOtp({
    required String verificationId,
    required String code,
  }) async =>
      const Err<AuthUser>(AuthFailure('not used'));

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      const Err<AuthUser>(AuthFailure('not used'));

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async =>
      const Err<AuthUser>(AuthFailure('not used'));

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async =>
      const Ok<void>(null);

  @override
  Future<void> signOut() async {}

  @override
  Stream<AuthUser?> authStateChanges() => const Stream<AuthUser?>.empty();

  @override
  AuthUser? get currentUser => null;
}

void main() {
  group('RequestOtp', () {
    test('rejects malformed input before touching the repository', () async {
      final _FakeRepository repo = _FakeRepository();
      final RequestOtp useCase = RequestOtp(repo);

      final Result<String> result = await useCase('123');

      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<ValidationFailure>());
      expect(repo.lastPhoneE164, isNull);
    });

    test('forwards a parsed phone to the repository', () async {
      final _FakeRepository repo = _FakeRepository();
      final RequestOtp useCase = RequestOtp(repo);

      final Result<String> result = await useCase('01712345678');

      expect(result, isA<Ok<String>>());
      expect((result as Ok<String>).value, 'vid-1');
      expect(repo.lastPhoneE164, '+8801712345678');
    });

    test('propagates repository errors', () async {
      final _FakeRepository repo = _FakeRepository()..nextError = 'rate limit';
      final RequestOtp useCase = RequestOtp(repo);

      final Result<String> result = await useCase('01712345678');

      expect(result, isA<Err<String>>());
      expect((result as Err<String>).failure, isA<ServerFailure>());
    });
  });
}
