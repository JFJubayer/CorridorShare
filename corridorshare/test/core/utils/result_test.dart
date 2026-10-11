import 'package:corridorshare/core/errors/failure.dart';
import 'package:corridorshare/core/utils/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Ok fold calls onSuccess', () {
      const Result<int> result = Ok<int>(42);
      final int value = result.fold((int v) => v, (Failure _) => -1);
      expect(value, 42);
    });

    test('Err fold calls onFailure', () {
      const Result<int> result = Err<int>(ValidationFailure('bad'));
      final String value = result.fold(
        (int v) => 'ok:$v',
        (Failure f) => 'err:${f.message}',
      );
      expect(value, 'err:bad');
    });

    test('getOrThrow unwraps Ok', () {
      const Result<String> result = Ok<String>('hello');
      expect(result.getOrThrow(), 'hello');
    });

    test('getOrThrow throws for Err', () {
      const Result<String> result = Err<String>(ValidationFailure('x'));
      expect(() => result.getOrThrow(), throwsStateError);
    });
  });
}
