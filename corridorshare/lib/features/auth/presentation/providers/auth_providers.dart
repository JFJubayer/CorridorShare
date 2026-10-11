import 'dart:async';

import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/data/datasources/auth_datasource.dart';
import 'package:corridorshare/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';
import 'package:corridorshare/features/auth/domain/usecases/request_otp.dart';
import 'package:corridorshare/features/auth/domain/usecases/verify_otp.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth state machine surfaced to widgets.
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.lastFailure});
  final Failure? lastFailure;
}

class AuthOtpRequested extends AuthState {
  const AuthOtpRequested({
    required this.verificationId,
    required this.phone,
    this.lastFailure,
  });
  final String verificationId;
  final String phone;
  final Failure? lastFailure;
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final AuthUser user;
}

extension AuthStateX on AuthState {
  bool get isAuthenticated => this is AuthAuthenticated;
  AuthUser? get user => switch (this) {
        AuthAuthenticated(:final user) => user,
        _ => null,
      };
}

/// Default data source used when the app boots without Firebase wired up.
/// Real Firebase wiring replaces this in Increment 1, part 2.
final Provider<AuthDataSource> authDataSourceProvider = Provider<AuthDataSource>(
  (Ref ref) => throw UnimplementedError(
    'Override authDataSourceProvider in ProviderScope for tests or with '
    'FirebaseAuthDataSource when FIREBASE_ENABLED=true.',
  ),
);

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
  (Ref ref) => AuthRepositoryImpl(ref.watch(authDataSourceProvider)),
);

final Provider<RequestOtp> requestOtpProvider = Provider<RequestOtp>(
  (Ref ref) => RequestOtp(ref.watch(authRepositoryProvider)),
);

final Provider<VerifyOtp> verifyOtpProvider = Provider<VerifyOtp>(
  (Ref ref) => VerifyOtp(ref.watch(authRepositoryProvider)),
);

/// Top-level auth controller. Owns the [AuthState] and reacts to repo
/// stream updates.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthInitial()) {
    final Stream<AuthUser?> stream =
        _ref.read(authRepositoryProvider).authStateChanges();
    _sub = stream.listen(_onUserChanged);
  }

  final Ref _ref;
  StreamSubscription<AuthUser?>? _sub;

  void _onUserChanged(AuthUser? user) {
    if (user == null) {
      if (state is! AuthOtpRequested) {
        state = const AuthUnauthenticated();
      }
      return;
    }
    state = AuthAuthenticated(user);
  }

  Future<void> requestOtp(String phone) async {
    final Result<String> result = await _ref.read(requestOtpProvider)(phone);
    state = result.fold(
      (verificationId) =>
          AuthOtpRequested(verificationId: verificationId, phone: phone),
      (failure) {
        final AuthState current = state;
        if (current is AuthOtpRequested) {
          return AuthOtpRequested(
            verificationId: current.verificationId,
            phone: current.phone,
            lastFailure: failure,
          );
        }
        return AuthUnauthenticated(lastFailure: failure);
      },
    );
  }

  Future<void> verifyOtp(String code) async {
    final AuthState current = state;
    if (current is! AuthOtpRequested) {
      return;
    }
    final Result<AuthUser> result = await _ref.read(verifyOtpProvider)(
      verificationId: current.verificationId,
      code: code,
    );
    result.fold(
      (user) {
        // The repo stream will also fire; this is a fast-path so the UI can
        // navigate immediately.
        state = AuthAuthenticated(user);
      },
      (failure) {
        state = AuthOtpRequested(
          verificationId: current.verificationId,
          phone: current.phone,
          lastFailure: failure,
        );
      },
    );
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<AuthController, AuthState> authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (Ref ref) => AuthController(ref),
);

/// Locale controller used by the language switch in the profile tab.
class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en'));

  void setLocale(Locale locale) {
    state = locale;
  }
}

final StateNotifierProvider<LocaleController, Locale> localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>(
  (Ref ref) => LocaleController(),
);