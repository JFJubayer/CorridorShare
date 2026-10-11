import 'package:corridorshare/core/errors/failure.dart';

/// A small algebraic result type used at the repository boundary.
///
/// Repositories return [Result] instead of throwing so that use cases and
/// notifiers can pattern-match without try/catch.
sealed class Result<T> {
  const Result();

  /// Run [onSuccess] for an [Ok] or [onFailure] for an [Err].
  R fold<R>(R Function(T value) onSuccess, R Function(Failure failure) onFailure);

  /// Returns the value or throws if this is [Err]. Use sparingly.
  T getOrThrow() => switch (this) {
        Ok<T>(:final value) => value,
        Err<T>(:final failure) => throw StateError(failure.toString()),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;

  @override
  R fold<R>(R Function(T value) onSuccess, R Function(Failure failure) onFailure) =>
      onSuccess(value);
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;

  @override
  R fold<R>(R Function(T value) onSuccess, R Function(Failure failure) onFailure) =>
      onFailure(failure);
}
