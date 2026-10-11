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
      (dto) => Ok<AuthUser>(
        AuthUser(
          id: dto.id,
          phone: dto.phone,
          name: dto.name,
          verified: dto.verified,
          ratingAvg: dto.ratingAvg,
        ),
      ),
      Err.new,
    );
  }

  @override
  Future<void> signOut() => _dataSource.signOut();

  @override
  Stream<AuthUser?> authStateChanges() => _dataSource.authStateChanges().map(
        (dto) => dto == null
            ? null
            : AuthUser(
                id: dto.id,
                phone: dto.phone,
                name: dto.name,
                verified: dto.verified,
                ratingAvg: dto.ratingAvg,
              ),
      );
}