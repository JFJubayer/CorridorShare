import 'package:corridorshare/core/utils/result.dart';
import 'package:corridorshare/features/auth/data/datasources/auth_datasource.dart';
import 'package:corridorshare/features/auth/domain/entities/auth_user.dart';
import 'package:corridorshare/features/auth/domain/entities/phone_number.dart';
import 'package:corridorshare/features/auth/domain/repositories/auth_repository.dart';

/// Bridges [AuthDataSource] (Firebase) to the [AuthRepository] domain
/// interface. The real Firebase implementation is wired in Increment 1,
/// part 2; the foundation ships a fake so the UI works end-to-end.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Future<Result<String>> requestOtp(PhoneNumber phone) =>
      _dataSource.requestOtp(phone);

  @override
  Future<Result<AuthUser>> verifyOtp({
    required String verificationId,
    required String code,
  }) async {
    final result = await _dataSource.verifyOtp(
      verificationId: verificationId,
      code: code,
    );
    return result.fold(
      (dto) => Ok<AuthUser>(_toEntity(dto)),
      Err.new,
    );
  }

  @override
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _dataSource.signInWithEmail(
      email: email,
      password: password,
    );
    return result.fold(
      (dto) => Ok<AuthUser>(_toEntity(dto)),
      Err.new,
    );
  }

  @override
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    final result = await _dataSource.signUpWithEmail(
      email: email,
      password: password,
      name: name,
    );
    return result.fold(
      (dto) => Ok<AuthUser>(_toEntity(dto)),
      Err.new,
    );
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) =>
      _dataSource.sendPasswordResetEmail(email);

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Stream<AuthUser?> authStateChanges() =>
      _dataSource.authStateChanges().map((dto) => dto == null ? null : _toEntity(dto));

  @override
  AuthUser? get currentUser {
    final dto = _dataSource.currentUser;
    return dto == null ? null : _toEntity(dto);
  }

  AuthUser _toEntity(dynamic dto) {
    return AuthUser(
      id: dto.id as String,
      phone: dto.phone as String,
      email: dto.email as String,
      name: dto.name as String,
      verified: dto.verified as bool,
      ratingAvg: dto.ratingAvg as double,
    );
  }
}