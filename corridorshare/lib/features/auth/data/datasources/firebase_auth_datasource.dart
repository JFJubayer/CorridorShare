import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/data/datasources/auth_datasource.dart';
import 'package:corridorshare/features/auth/data/models/user_dto.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Real Firebase implementation of [AuthDataSource].
///
/// Handles both Phone SMS OTP verification and Email/Password authentication,
/// and synchronizes authenticated user profile state with Cloud Firestore (`users/{uid}`).
class FirebaseAuthDataSource implements AuthDataSource {
  FirebaseAuthDataSource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  UserDto? get currentUser {
    final User? user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return UserDto(
      id: user.uid,
      phone: user.phoneNumber ?? '',
      email: user.email ?? '',
      name: user.displayName ?? '',
      verified: user.emailVerified || (user.phoneNumber != null && user.phoneNumber!.isNotEmpty),
      ratingAvg: 5.0,
    );
  }

  @override
  Future<Result<String>> requestOtp(PhoneNumber phone) async {
    final Completer<Result<String>> completer = Completer<Result<String>>();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone.e164,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final UserCredential userCredential =
                await _auth.signInWithCredential(credential);
            final User? user = userCredential.user;
            if (user != null) {
              await _syncUserDocument(user, phoneOverride: phone.e164);
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint('Auto verification sign-in failed: $e');
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.complete(Err<String>(_mapFirebaseException(e)));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            completer.complete(Ok<String>(verificationId));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(Ok<String>(verificationId));
          }
        },
      );
    } on FirebaseAuthException catch (e) {
      if (!completer.isCompleted) {
        completer.complete(Err<String>(_mapFirebaseException(e)));
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(Err<String>(AuthFailure(e.toString())));
      }
    }

    return completer.future;
  }

  @override
  Future<Result<UserDto>> verifyOtp({
    required String verificationId,
    required String code,
  }) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code.trim(),
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) {
        return const Err<UserDto>(AuthFailure('Sign-in failed. Please try again.'));
      }
      final UserDto dto = await _syncUserDocument(user);
      return Ok<UserDto>(dto);
    } on FirebaseAuthException catch (e) {
      return Err<UserDto>(_mapFirebaseException(e));
    } catch (e) {
      return Err<UserDto>(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserDto>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = userCredential.user;
      if (user == null) {
        return const Err<UserDto>(AuthFailure('Sign-in failed. Please try again.'));
      }
      final UserDto dto = await _syncUserDocument(user);
      return Ok<UserDto>(dto);
    } on FirebaseAuthException catch (e) {
      return Err<UserDto>(_mapFirebaseException(e));
    } catch (e) {
      return Err<UserDto>(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserDto>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? user = userCredential.user;
      if (user == null) {
        return const Err<UserDto>(AuthFailure('Sign-up failed. Please try again.'));
      }
      if (name != null && name.trim().isNotEmpty) {
        await user.updateDisplayName(name.trim());
      }
      final UserDto dto = await _syncUserDocument(user, nameOverride: name?.trim());
      return Ok<UserDto>(dto);
    } on FirebaseAuthException catch (e) {
      return Err<UserDto>(_mapFirebaseException(e));
    } catch (e) {
      return Err<UserDto>(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Ok<void>(null);
    } on FirebaseAuthException catch (e) {
      return Err<void>(_mapFirebaseException(e));
    } catch (e) {
      return Err<void>(AuthFailure(e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<UserDto?> authStateChanges() {
    return _auth.authStateChanges().asyncExpand((User? firebaseUser) {
      if (firebaseUser == null) {
        return Stream<UserDto?>.value(null);
      }
      return _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
        if (!snapshot.exists || snapshot.data() == null) {
          return UserDto(
            id: firebaseUser.uid,
            phone: firebaseUser.phoneNumber ?? '',
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? '',
            verified: firebaseUser.emailVerified ||
                (firebaseUser.phoneNumber != null &&
                    firebaseUser.phoneNumber!.isNotEmpty),
            ratingAvg: 5.0,
          );
        }
        final Map<String, dynamic> data = snapshot.data()!;
        return UserDto(
          id: firebaseUser.uid,
          phone: (data['phone'] as String?) ?? firebaseUser.phoneNumber ?? '',
          email: (data['email'] as String?) ?? firebaseUser.email ?? '',
          name: (data['name'] as String?) ?? firebaseUser.displayName ?? '',
          verified: (data['verified'] as bool?) ?? false,
          ratingAvg: ((data['ratingAvg'] as num?) ?? 5.0).toDouble(),
        );
      });
    });
  }

  /// Synchronizes the user document with Cloud Firestore (`users/{uid}`).
  Future<UserDto> _syncUserDocument(
    User user, {
    String? nameOverride,
    String? phoneOverride,
  }) async {
    final DocumentReference<Map<String, dynamic>> docRef =
        _firestore.collection('users').doc(user.uid);
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();

    final String phone = phoneOverride ?? user.phoneNumber ?? '';
    final String email = user.email ?? '';
    final String name = nameOverride ?? user.displayName ?? '';

    if (!snapshot.exists) {
      final UserDto newUser = UserDto(
        id: user.uid,
        phone: phone,
        email: email,
        name: name,
        verified: user.emailVerified || phone.isNotEmpty,
        ratingAvg: 5.0,
      );

      await docRef.set(<String, dynamic>{
        'id': newUser.id,
        'phone': newUser.phone,
        'email': newUser.email,
        'name': newUser.name,
        'verified': newUser.verified,
        'ratingAvg': newUser.ratingAvg,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return newUser;
    } else {
      final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
      final Map<String, dynamic> updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if ((data['email'] as String?)?.isEmpty ?? true) {
        if (email.isNotEmpty) {
          updates['email'] = email;
        }
      }
      if ((data['phone'] as String?)?.isEmpty ?? true) {
        if (phone.isNotEmpty) {
          updates['phone'] = phone;
        }
      }
      if ((data['name'] as String?)?.isEmpty ?? true) {
        if (name.isNotEmpty) {
          updates['name'] = name;
        }
      }

      if (updates.length > 1) {
        await docRef.update(updates);
      }

      return UserDto(
        id: user.uid,
        phone: (data['phone'] as String?) ?? phone,
        email: (data['email'] as String?) ?? email,
        name: (data['name'] as String?) ?? name,
        verified: (data['verified'] as bool?) ?? false,
        ratingAvg: ((data['ratingAvg'] as num?) ?? 5.0).toDouble(),
      );
    }
  }

  Failure _mapFirebaseException(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-phone-number' =>
        const ValidationFailure('Invalid phone number format.'),
      'invalid-verification-code' =>
        const ValidationFailure('The 6-digit verification code is invalid.'),
      'session-expired' =>
        const AuthFailure('Verification session expired. Please request a new code.'),
      'user-not-found' =>
        const AuthFailure('No account found for this email address.'),
      'wrong-password' =>
        const AuthFailure('Incorrect password. Please try again.'),
      'invalid-credential' =>
        const AuthFailure('Invalid credentials provided. Check your details and try again.'),
      'email-already-in-use' =>
        const AuthFailure('An account already exists with this email address.'),
      'invalid-email' =>
        const ValidationFailure('The email address is badly formatted.'),
      'weak-password' =>
        const ValidationFailure('The password is too weak. Choose at least 6 characters.'),
      'network-request-failed' =>
        const NetworkFailure('Network error. Check your internet connection.'),
      'too-many-requests' =>
        const AuthFailure('Too many attempts. Please try again in a few minutes.'),
      _ => AuthFailure(e.message ?? 'Authentication error occurred.'),
    };
  }
}
