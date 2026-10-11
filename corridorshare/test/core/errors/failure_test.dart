import 'package:corridorshare/core/errors/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('toString includes the runtime type and message', () {
      const Failure failure = ValidationFailure('bad phone');
      expect(failure.toString(), 'ValidationFailure(bad phone)');
    });

    test('default messages for the common subtypes', () {
      expect(const NetworkFailure().message, 'No connection');
      expect(const AuthFailure().message, 'Authentication required');
      expect(const NotFoundFailure().message, 'Not found');
      expect(const UnknownFailure().message, 'Something went wrong');
    });
  });
}
