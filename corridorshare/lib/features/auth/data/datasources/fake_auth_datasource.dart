import 'dart:async';

import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/data/datasources/auth_datasource.dart';
import 'package:corridorshare/features/auth/data/models/user_dto.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';

/// In-memory [AuthDataSource] used in the foundation slice.
///
/// The fake accepts any 6-digit OTP and signs the user in. It is overridden
/// in `ProviderScope` at app start so the UI can be exercised without
/// Firebase. Tests inject their own fake.
class FakeAuthDataSource implements AuthDataSource {
  final StreamController<UserDto?> _controller = StreamController<UserDto?>.broadcast();
  String? _lastVerificationId;
  String? _lastPhone;
  static int _counter = 0;

  @override
  Future<Result<String>> requestOtp(PhoneNumber phone) async {
    _lastVerificationId = 'fake-${++_counter}';
    _lastPhone = phone.e164;
    return Ok<String>(_lastVerificationId!);
  }

  @override
  Future<Result<UserDto>> verifyOtp({
    required String verificationId,
    required String code,
  }) async {
    if (verificationId != _lastVerificationId) {
      return const Err<UserDto>(AuthFailure('Session expired, retry'));
    }
    if (code.length != 6 || !RegExp(r'^\d{6}$').hasMatch(code)) {
      return const Err<UserDto>(ValidationFailure('OTP must be 6 digits'));
    }
    final UserDto user = UserDto(
      id: 'fake-uid-${_lastPhone ?? 'unknown'}',
      phone: _lastPhone ?? '',
      name: '',
      verified: false,
      ratingAvg: 0,
    );
    _controller.add(user);
    return Ok<UserDto>(user);
  }

  @override
  Future<void> signOut() async {
    _controller.add(null);
  }

  @override
  Stream<UserDto?> authStateChanges() => _controller.stream;
}
