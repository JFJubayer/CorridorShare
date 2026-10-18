import 'dart:async';

import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/data/datasources/auth_datasource.dart';
import 'package:corridorshare/features/auth/data/models/user_dto.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';

/// Internal registered account record storing credentials and profile.
class RegisteredUserAccount {
  const RegisteredUserAccount({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    this.phone = '',
    this.verified = true,
    this.ratingAvg = 5.0,
  });

  final String id;
  final String email;
  final String password;
  final String name;
  final String phone;
  final bool verified;
  final double ratingAvg;

  UserDto toDto() => UserDto(
        id: id,
        email: email,
        phone: phone,
        name: name,
        verified: verified,
        ratingAvg: ratingAvg,
      );
}

/// In-memory [AuthDataSource] with an internal registered user database.
///
/// Only pre-registered or newly signed up users can sign in.
/// Any unknown identifier or invalid password will be rejected.
class FakeAuthDataSource implements AuthDataSource {
  final StreamController<UserDto?> _controller =
      StreamController<UserDto?>.broadcast();
  String? _lastVerificationId;
  String? _lastPhone;
  static int _counter = 0;

  /// In-memory registry of registered user accounts shared across instances.
  static final Map<String, RegisteredUserAccount> _registeredUsers =
      <String, RegisteredUserAccount>{
    'test@example.com': const RegisteredUserAccount(
      id: 'fake-uid-test',
      email: 'test@example.com',
      password: 'password123',
      name: 'Test User',
      phone: '+8801700000001',
      verified: true,
      ratingAvg: 5.0,
    ),
    'admin@corridorshare.com': const RegisteredUserAccount(
      id: 'fake-uid-admin',
      email: 'admin@corridorshare.com',
      password: 'admin123',
      name: 'Admin Officer',
      phone: '+8801700000000',
      verified: true,
      ratingAvg: 5.0,
    ),
    'rahim@corridorshare.com': const RegisteredUserAccount(
      id: 'fake-uid-rahim',
      email: 'rahim@corridorshare.com',
      password: 'password123',
      name: 'Rahim Ahmed',
      phone: '+8801712345678',
      verified: true,
      ratingAvg: 4.9,
    ),
    'karim@corridorshare.com': const RegisteredUserAccount(
      id: 'fake-uid-karim',
      email: 'karim@corridorshare.com',
      password: 'password123',
      name: 'Karim Ullah',
      phone: '+8801812345678',
      verified: true,
      ratingAvg: 4.8,
    ),
    'demo@corridorshare.com': const RegisteredUserAccount(
      id: 'fake-uid-demo',
      email: 'demo@corridorshare.com',
      password: 'demo1234',
      name: 'Demo User',
      phone: '+8801912345678',
      verified: true,
      ratingAvg: 5.0,
    ),
  };

  /// Find user by email, user ID, username prefix, or phone number.
  static RegisteredUserAccount? findUser(String identifier) {
    final String clean = identifier.trim().toLowerCase();
    if (_registeredUsers.containsKey(clean)) {
      return _registeredUsers[clean];
    }
    final String cleanDigits = _digitsOnly(clean);
    for (final RegisteredUserAccount user in _registeredUsers.values) {
      if (user.id.toLowerCase() == clean ||
          user.email.split('@').first.toLowerCase() == clean) {
        return user;
      }
      if (cleanDigits.length >= 10 && user.phone.isNotEmpty) {
        final String userDigits = _digitsOnly(user.phone);
        if (userDigits.length >= 10) {
          final String userLast10 = userDigits.substring(userDigits.length - 10);
          final String cleanLast10 = cleanDigits.substring(cleanDigits.length - 10);
          if (userLast10 == cleanLast10) {
            return user;
          }
        }
      }
    }
    return null;
  }

  static String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  /// Manually add a registered user (useful for test setup).
  static void registerUser(RegisteredUserAccount user) {
    _registeredUsers[user.email.trim().toLowerCase()] = user;
  }

  /// Reset the database to initial seed accounts.
  static void resetDatabase() {
    _registeredUsers.clear();
    _registeredUsers.addAll(<String, RegisteredUserAccount>{
      'test@example.com': const RegisteredUserAccount(
        id: 'fake-uid-test',
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
        phone: '+8801700000001',
        verified: true,
        ratingAvg: 5.0,
      ),
      'admin@corridorshare.com': const RegisteredUserAccount(
        id: 'fake-uid-admin',
        email: 'admin@corridorshare.com',
        password: 'admin123',
        name: 'Admin Officer',
        phone: '+8801700000000',
        verified: true,
        ratingAvg: 5.0,
      ),
      'rahim@corridorshare.com': const RegisteredUserAccount(
        id: 'fake-uid-rahim',
        email: 'rahim@corridorshare.com',
        password: 'password123',
        name: 'Rahim Ahmed',
        phone: '+8801712345678',
        verified: true,
        ratingAvg: 4.9,
      ),
      'karim@corridorshare.com': const RegisteredUserAccount(
        id: 'fake-uid-karim',
        email: 'karim@corridorshare.com',
        password: 'password123',
        name: 'Karim Ullah',
        phone: '+8801812345678',
        verified: true,
        ratingAvg: 4.8,
      ),
      'demo@corridorshare.com': const RegisteredUserAccount(
        id: 'fake-uid-demo',
        email: 'demo@corridorshare.com',
        password: 'demo1234',
        name: 'Demo User',
        phone: '+8801912345678',
        verified: true,
        ratingAvg: 5.0,
      ),
    });
  }

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
    final RegisteredUserAccount? existing = findUser(_lastPhone ?? '');
    final UserDto user = existing != null
        ? existing.toDto()
        : UserDto(
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
    final String cleanIdentifier = email.trim();
    if (cleanIdentifier.isEmpty) {
      return const Err<UserDto>(
          ValidationFailure('Please enter your email or user ID'));
    }
    if (cleanIdentifier.contains('@') &&
        (!cleanIdentifier.contains('.') || cleanIdentifier.length < 5)) {
      return const Err<UserDto>(ValidationFailure('Invalid email address'));
    }
    if (password.isEmpty) {
      return const Err<UserDto>(
          ValidationFailure('Please enter your password'));
    }

    final RegisteredUserAccount? user = findUser(cleanIdentifier);
    if (user == null) {
      return const Err<UserDto>(AuthFailure(
          'No registered account found. Please check your credentials or sign up.'));
    }

    if (user.password != password) {
      return const Err<UserDto>(
          AuthFailure('Incorrect password. Please try again.'));
    }

    final UserDto dto = user.toDto();
    _currentUser = dto;
    _controller.add(dto);
    return Ok<UserDto>(dto);
  }

  @override
  Future<Result<UserDto>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    final String cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return const Err<UserDto>(ValidationFailure('Invalid email address'));
    }
    if (password.length < 6) {
      return const Err<UserDto>(
          ValidationFailure('Password must be at least 6 characters'));
    }

    if (findUser(cleanEmail) != null) {
      return const Err<UserDto>(AuthFailure(
          'An account with this email is already registered. Please sign in.'));
    }

    final String generatedId = 'user-${DateTime.now().millisecondsSinceEpoch}';
    final RegisteredUserAccount newUser = RegisteredUserAccount(
      id: generatedId,
      email: cleanEmail,
      password: password,
      name: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : cleanEmail.split('@').first,
      verified: false,
      ratingAvg: 5.0,
    );

    _registeredUsers[cleanEmail] = newUser;
    final UserDto dto = newUser.toDto();
    _currentUser = dto;
    _controller.add(dto);
    return Ok<UserDto>(dto);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      return const Err<void>(ValidationFailure('Invalid email address'));
    }
    if (findUser(email) == null) {
      return const Err<void>(
          AuthFailure('No registered account found with this email.'));
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
