import 'dart:async';

import 'package:corridorshare/core/di/injection.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/usecases/request_otp.dart';
import 'package:corridorshare/features/auth/domain/usecases/send_password_reset.dart';
import 'package:corridorshare/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:corridorshare/features/auth/domain/usecases/sign_out.dart';
import 'package:corridorshare/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:corridorshare/features/auth/domain/usecases/verify_otp.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:corridorshare/core/di/injection.dart'
    show authDataSourceProvider, authRepositoryProvider;

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

final Provider<RequestOtp> requestOtpProvider = Provider<RequestOtp>(
  (Ref ref) => RequestOtp(ref.watch(authRepositoryProvider)),
);

final Provider<VerifyOtp> verifyOtpProvider = Provider<VerifyOtp>(
  (Ref ref) => VerifyOtp(ref.watch(authRepositoryProvider)),
);

final Provider<SignInWithEmail> signInWithEmailProvider = Provider<SignInWithEmail>(
  (Ref ref) => SignInWithEmail(ref.watch(authRepositoryProvider)),
);

final Provider<SignUpWithEmail> signUpWithEmailProvider = Provider<SignUpWithEmail>(
  (Ref ref) => SignUpWithEmail(ref.watch(authRepositoryProvider)),
);

final Provider<SendPasswordReset> sendPasswordResetProvider = Provider<SendPasswordReset>(
  (Ref ref) => SendPasswordReset(ref.watch(authRepositoryProvider)),
);

final Provider<SignOut> signOutProvider = Provider<SignOut>(
  (Ref ref) => SignOut(ref.watch(authRepositoryProvider)),
);

/// Top-level auth controller. Owns the [AuthState] and reacts to repo
/// stream updates.
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthInitial()) {
    final Stream<AuthUser?> stream =
        _ref.read(authRepositoryProvider).authStateChanges();
    _sub = stream.listen(_onUserChanged);
    final AuthUser? current = _ref.read(authRepositoryProvider).currentUser;
    if (current != null) {
      state = AuthAuthenticated(current);
    }
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
        // Fast-path so the UI can navigate immediately.
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

  Future<Result<AuthUser>> signInWithEmail(String email, String password) async {
    final Result<AuthUser> result = await _ref.read(signInWithEmailProvider)(
      email: email,
      password: password,
    );
    result.fold(
      (user) => state = AuthAuthenticated(user),
      (failure) => state = AuthUnauthenticated(lastFailure: failure),
    );
    return result;
  }

  Future<Result<AuthUser>> signUpWithEmail(
    String email,
    String password, {
    String? name,
  }) async {
    final Result<AuthUser> result = await _ref.read(signUpWithEmailProvider)(
      email: email,
      password: password,
      name: name,
    );
    result.fold(
      (user) => state = AuthAuthenticated(user),
      (failure) => state = AuthUnauthenticated(lastFailure: failure),
    );
    return result;
  }

  Future<Result<void>> sendPasswordReset(String email) async {
    return _ref.read(sendPasswordResetProvider)(email);
  }

  Future<void> signOut() async {
    await _ref.read(signOutProvider)();
    state = const AuthUnauthenticated();
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

/// Helper provider returning the currently authenticated user if logged in.
final Provider<AuthUser?> currentUserProvider = Provider<AuthUser?>((Ref ref) {
  final AuthState authState = ref.watch(authControllerProvider);
  return authState.user;
});

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