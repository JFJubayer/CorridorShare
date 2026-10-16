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
    _currentUser = user;
    _controller.add(user);
    return Ok<UserDto>(user);
  }

  UserDto? _currentUser;

  @override
  UserDto? get currentUser => _currentUser;

  @override
  Future<Result<UserDto>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      return const Err<UserDto>(ValidationFailure('Invalid email address'));
    }
    if (password.length < 6) {
      return const Err<UserDto>(ValidationFailure('Password must be at least 6 characters'));
    }
    final UserDto user = UserDto(
      id: 'fake-uid-${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      email: email,
      name: email.split('@').first,
      verified: true,
      ratingAvg: 5.0,
    );
    _currentUser = user;
    _controller.add(user);
    return Ok<UserDto>(user);
  }

  @override
  Future<Result<UserDto>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    if (email.isEmpty || !email.contains('@')) {
      return const Err<UserDto>(ValidationFailure('Invalid email address'));
    }
    if (password.length < 6) {
      return const Err<UserDto>(ValidationFailure('Password must be at least 6 characters'));
    }
    final UserDto user = UserDto(
      id: 'fake-uid-${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      email: email,
      name: name ?? email.split('@').first,
      verified: false,
      ratingAvg: 5.0,
    );
    _currentUser = user;
    _controller.add(user);
    return Ok<UserDto>(user);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      return const Err<void>(ValidationFailure('Invalid email address'));
    }
    return const Ok<void>(null);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Stream<UserDto?> authStateChanges() => _controller.stream;
}
